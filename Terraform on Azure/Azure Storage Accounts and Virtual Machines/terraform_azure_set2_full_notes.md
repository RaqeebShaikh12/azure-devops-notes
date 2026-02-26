
# Terraform on Azure – Service Principal & Storage Notes (Set 2)

## 17. Authenticating Terraform Using an Application Object (Service Principal)
Earlier, Terraform authentication used:
- Azure AD User
- Azure CLI Login

Now we move to a **production-ready authentication method**:
✔ **Azure AD Application + Service Principal**

### Why Use an Application Object?
```
+------------------+       +-----------------------+
| Azure AD User    |  OR   | Azure AD Application  |
| (Human identity) |       | + Service Principal   |
+------------------+       +-----------------------+
```

### Users
- Human login
- Not ideal for automation
- Password rotation & sign-in complexity

### Application Object (Service Principal)
- Non‑human identity
- Best for automation workflows
- Uses **Client ID + Secret + Tenant ID**
- Fine‑grained RBAC permissions

---
## 18. Creating the Application Object (Service Principal)
Steps performed:
1. Azure Portal → **Microsoft Entra ID** → **App registrations**
2. Click **New Registration**
3. Choose name (e.g., `tf-app`)
4. Register application

### Diagram: App Registration Flow
```
Microsoft Entra ID
     |
     +--> App Registrations
             |
             +--> Create Application
                     |
                     +--> Generates:
                            • Application (client) ID
                            • Directory (tenant) ID
                            • Service Principal
```

---
## 19. Assigning RBAC Permissions to the Application
Removed the previous Terraform user permissions.
Added RBAC permissions to the Application.

Path:
**Azure Portal → Subscription → Access Control (IAM)**

Role Assigned:
- **Contributor** (broad access, OK for learning)

### Diagram: Service Principal Role Flow
```
Terraform
   |
   v
Service Principal (ClientID + Secret)
   |
   v
Azure AD --> Authenticates --> Issues token
   |
   v
Azure RBAC --> Checks Contributor Role
   |
   v
Azure Subscription --> Resource deployment allowed
```

---
## 20. Adding Authentication Values to Terraform
Provider block:
```
provider "azurerm" {
  features {}
  subscription_id = "<subscription-id>"
  client_id       = "<app-client-id>"
  client_secret   = "<generated-secret-value>"
  tenant_id       = "<tenant-id>"
}
```

### Source of values
- **Client ID** → App Registration (Overview)
- **Tenant ID** → Directory ID
- **Client Secret** → Certificates & Secrets → *New client secret*

⚠ **Important:** Secret value cannot be retrieved again once page is left.

---
## 21. Re‑running Terraform Workflow with Service Principal
Performed workflow:
1. Deleted existing resource group
2. Saved modified `main.tf`
3. Created plan:
```
terraform plan -out main.tfplan
```
4. Applied the plan:
```
terraform apply main.tfplan
```
Terraform recreated the Resource Group using **Service Principal authentication**.

---
## 22. Understanding Azure Storage Accounts (Before Automating)
Type: **General Purpose v2 (GPv2)**

Features include:
- Blob Storage (files, videos, images)
- Azure File Shares
- Queues
- Tables

### Blob Storage Structure
```
Storage Account
     |
     +-- Container (folder-like)
              |
              +-- Blob (file/object)
```

Manual steps performed:
- Created storage account
- Created a container
- Uploaded a file (stored as binary blob)

Then deleted the storage account to rebuild using Terraform.

---
## 23. Creating Storage Account Using Terraform
Terraform block:
```
resource "azurerm_storage_account" "appstorage" {
  name                     = "appstorage12345"
  resource_group_name      = "app-grp"
  location                 = "North Europe"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```

### Diagram: Flow
```
Terraform (.tf)
    |
    v
Resource Block: azurerm_storage_account
    |
    v
Azure Storage Account Created
```

Plan result: **1 to add**

Apply completed → new Storage Account appeared.

---
## 24. Creating Container + Uploading Blob via Terraform
### Storage Container Block
```
resource "azurerm_storage_container" "scripts" {
  name                  = "scripts"
  storage_account_name  = "appstorage12345"
}
```

### Blob Upload Block
```
resource "azurerm_storage_blob" "script01" {
  name                   = "script01.ps1"
  storage_account_name   = "appstorage12345"
  storage_container_name = "scripts"
  type                   = "Block"
  source                 = "script01.ps1"
}
```

Terraform created:
- Container **scripts**
- Blob **script01.ps1** uploaded into it

### Diagram: Blob Upload Flow
```
Local Machine
   |
   | source file (script01.ps1)
   v
Terraform Blob Resource
   |
   v
Azure Storage Account
   |
   v
Container --> Blob uploaded
```

---
## 25. Review of What We Have Built So Far
### ✔ Infrastructure
```
Resource Group
   |
   +-- Storage Account
          |
          +-- Container
          |      |
          |      +-- Blob (script01.ps1)
```

### ✔ Terraform Workflow Used
- Write configuration
- terraform plan
- terraform apply

### ✔ Concepts Learned
- Resource blocks
- Arguments
- Provider configuration
- Authentication methods
- State management
- Multi‑resource orchestration

Terraform now manages these Azure resources automatically.

