
# Azure SQL Database – Terraform Deployment (Part 3)

## 1. Introduction to Azure SQL Database (PaaS)
Azure SQL Database is a fully managed relational database service based on Microsoft SQL Server.
It removes the need to:
- Create a VM
- Install SQL Server
- Perform OS-level patching
- Manage backups and high availability

Azure handles these responsibilities automatically, allowing teams to focus on data and application logic.

Similar managed services include:
- Azure Database for MySQL
- Azure Database for PostgreSQL

---

## 2. Deploying SQL Database via Azure Portal (Overview)
Steps demonstrated:
1. Create a Resource Group
2. Create SQL Database
3. Configure SQL Server (name, region, admin login/password)
4. Choose compute tier (Basic / DTU model)
5. Enable public access and add client IP

### DTU (Database Transaction Unit) Model
A blended measure of CPU + memory + I/O. Basic tier → low-cost development DB.

When deployed, Azure creates:
- **SQL Server** (logical server with firewall + authentication)
- **SQL Database** (data container inside the server)

---

## 3. Deploying SQL Server and SQL Database via Terraform
Your Terraform variable structure:
```hcl
variable "db_environment" {
  type = map(object({
    server = map(object({
      sku     = string
      db_name = string
    }))
  }))
}
```

### Example `terraform.tfvars`
```hcl
db_environment = {
  production = {
    server = {
      sqlserverdemo123 = {
        sku     = "Basic"
        db_name = "mydatabase"
      }
    }
  }
}
```

---

## 4. Creating SQL Server (Terraform)
```hcl
resource "azurerm_mssql_server" "sqlserver" {
  for_each            = var.db_environment.production.server
  name                = each.key
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  administrator_login          = "azureuser"
  administrator_login_password = "AzureR33456"
}
```

---

## 5. Creating SQL Database (Terraform)
```hcl
resource "azurerm_mssql_database" "sqldb" {
  for_each  = var.db_environment.production.server
  name      = each.value.db_name
  server_id = azurerm_mssql_server.sqlserver[each.key].id

  sku_name = each.value.sku  # Basic
}
```

**Key mapping:**
- `each.key` → server name
- `each.value.db_name` → DB name

---

## 6. SQL Firewall Rule – Allowing Client IP Address
When attempting login via Query Editor, Azure blocks access:
> "Client with IP address X is not allowed to access the server."

Terraform solution:
```hcl
resource "azurerm_mssql_firewall_rule" "client_rule" {
  name            = "AllowClientIP"
  server_id       = azurerm_mssql_server.sqlserver["sqlserverdemo123"].id
  start_ip_address = "YOUR.IP.ADDRESS"
  end_ip_address   = "YOUR.IP.ADDRESS"
}
```

After apply → Query Editor connects successfully.

---

## 7. SQL Server vs SQL Database (Important Concept)
| Component | Purpose |
|----------|---------|
| **SQL Server** | Authentication, firewall rules, endpoint
| **SQL Database** | Storage container for tables, indexes, schemas |

Terraform requires referencing the **server ID** for DB creation.

---

## 8. Optional Hardening – prevent_destroy
```hcl
lifecycle {
  prevent_destroy = true
}
```
Prevents accidental deletion of production databases.

---

## 9. Summary
You learned:
- Difference between SQL Server & SQL Database
- DTU model basics
- Deploying SQL DB via Portal
- Deploying SQL Server & DB via Terraform
- Creating firewall rules with Terraform
- Understanding Terraform key/value structure during DB provisioning

---
# End of Part 3 Notes
