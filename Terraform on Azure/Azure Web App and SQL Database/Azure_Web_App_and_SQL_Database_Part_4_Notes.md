
# Azure SQL Database & Web App Integration – Advanced Terraform Concepts (Part 4)

## 1. Creating Multiple Databases on the Same SQL Server
Azure SQL Servers can host multiple databases, similar to how an App Service Plan can host multiple web apps.

To support multi‑environment, multi‑server, and multi‑database structures, we enhanced our input variable design:

- **Environment → Server → Databases**
- Each database has its own **SKU** and optional **sample DB** setting

This nested map structure mirrors real-world enterprise infrastructure layouts.

---

## 2. Updated Input Variable Structure
Example:
```hcl
server = {
  sqlserver01 = {
    databases = {
      coredb = {
        sku       = "S0"
        sample_db = null
      }
      appdb = {
        sku       = "S0"
        sample_db = "AdventureWorksLT"
      }
    }
  }
}
```

Here:
- Database **key** = database name
- Each DB has its own `sku` and optional `sample_db`

---

## 3. The Challenge: Nested Maps Are Hard to Loop Through
Terraform `for_each` requires:
- A **map**, or
- A **set of strings**

But our input is a *map of map of objects*.

So we flatten it.

---

## 4. Flattening Nested Structures Using `flatten()` + `for` Expressions
Objective: convert nested structures into a clean list of objects:

```hcl
locals {
  database_details = flatten([
    for server_key, server_val in var.db_environment.production.server : [
      for db_key, db_val in server_val.databases : {
        server_name = server_key
        db_name     = db_key
        sku         = db_val.sku
        sample_db   = db_val.sample_db
      }
    ]
  ])
}
```

### Output example:
```json
[
  {
    "server_name": "sqlserver01",
    "db_name": "coredb",
    "sku": "S0",
    "sample_db": null
  },
  {
    "server_name": "sqlserver01",
    "db_name": "appdb",
    "sku": "S0",
    "sample_db": "AdventureWorksLT"
  }
]
```

This gives Terraform a clean, loop-friendly structure.

---

## 5. Converting the Flat List Into a Map for `for_each`
Terraform database block:

```hcl
for_each = {
  for detail in local.database_details :
  detail.db_name => detail
}
```

Now each database becomes:
```
key = db_name
value = object containing server, sku, sample_db
```

---

## 6. Creating Multiple SQL Databases (Terraform)
```hcl
resource "azurerm_mssql_database" "sqldb" {
  for_each = {
    for detail in local.database_details :
    detail.db_name => detail
  }

  name      = each.value.db_name
  server_id = azurerm_mssql_server.sqlserver[each.value.server_name].id
  sku_name  = each.value.sku
  sample_name = each.value.sample_db
}
```

### Result:
- `coredb` created with no sample data
- `appdb` created with **AdventureWorksLT** built-in sample schema

---

## 7. Bootstrapping a Database With Custom SQL Scripts
A `null_resource` + `local-exec` provisioner lets you execute SQL scripts from your local machine.

Example script (`01.sql`):
```sql
CREATE TABLE Course (
  CourseID int,
  CourseName varchar(50),
  Rating int
);
INSERT INTO Course VALUES (1, 'Terraform Basics', 5);
INSERT INTO Course VALUES (2, 'Azure Fundamentals', 4);
INSERT INTO Course VALUES (3, 'DevOps Pipeline', 5);
```

### Terraform resource:
```hcl
resource "null_resource" "database_setup" {
  provisioner "local-exec" {
    command = "sqlcmd -S ${serverFQDN} -U sqladmin -P AzureR33456 -d appdb -i 01.sql"
  }
}
```

Once applied → table + rows are inserted.

---

## 8. Deploying Web App That Connects to SQL Database
You built an end‑to‑end example:

### Steps:
1. Develop .NET app → contains UI + SQL connection logic
2. Push code to GitHub repository
3. Terraform deploys:
   - App Service Plan
   - Web App
   - Connection Strings
   - Source control integration
4. Azure Web App pulls code from GitHub and deploys automatically
5. App reads data from SQL database and displays it

---

## 9. Configuring SQL Connection String in Web App
```hcl
connection_string {
  name  = "AZURE_SQL_CONNECTION_STRING"
  type  = "SQLAzure"
  value = "Server=...;Database=...;User ID=...;Password=...;"
}
```

The .NET app reads:
```
Configuration.GetConnectionString("AZURE_SQL_CONNECTION_STRING")
```

---

## 10. Allowing Azure Web App to Access SQL Server
Firewall rule:

```hcl
resource "azurerm_mssql_firewall_rule" "allow_azure" {
  name            = "AllowAzureIPs"
  server_id       = azurerm_mssql_server.sqlserver[each.key].id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}
```

This enables:
- Web Apps
- Azure Functions
- Logic Apps
… to access SQL Server.

---

## 11. Deploying From GitHub
Using:
```hcl
resource "azurerm_app_service_source_control" "source" {
  app_id   = azurerm_windows_web_app.webapp.id
  repo_url = "https://github.com/<user>/<repo>"
  branch   = "main"
}
```

Azure automatically:
- Pulls code
- Builds it
- Deploys to App Service

---

## 12. Final Result
- A working .NET web app hosted on Azure Web Apps
- Connected to Azure SQL Database
- Displays SQL table data
- Code stored and version-controlled in GitHub
- Entire infrastructure deployed using Terraform

---
# End of Part 4 Notes
