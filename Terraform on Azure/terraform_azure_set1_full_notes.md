# Terraform on Azure – Set 1 Notes (Complete)

## 🌱 Terraform on Azure – Notes (Set 1)
(Accumulating until user says stop)

### 1. What is Terraform?
Terraform is an Infrastructure as Code (IaC) tool by HashiCorp that lets you:
- Define infrastructure using configuration files.
- Deploy, change, and destroy resources consistently and automatically.
- Avoid manual provisioning errors.
- Recreate environments on demand (dev → test → destroy → recreate).

### Why companies use Terraform
Scenario:
- Company needs 2 VMs + 1 Storage Account + 1 Azure SQL DB.
- Recreating test infrastructure manually is:
  - Time-consuming
  - Error-prone
  - Costly if not cleaned up

Terraform solves this by deploying the environment from code repeatedly and consistently.

---
### 2. How Terraform Works (High-Level)

#### 🔧 Components
**Configuration Files (.tf / .tf.json)** – Declare infrastructure.

**Terraform CLI** – Executes provisioning commands.

**Providers** – Plugins connecting Terraform to cloud APIs (Azure, AWS, GCP).
AzureRM provider uses Azure REST APIs.

#### 🌐 Multi‑Cloud Strength
Terraform works across cloud providers unlike vendor-specific IaC tools.

---
### 3. Terraform Workflow (Write → Plan → Apply)

**Step 1: Write** – Author .tf configuration.

**Step 2: Plan** – `terraform plan` compares existing infra vs. configuration.

**Step 3: Apply** – `terraform apply` provisions resources.

Workflow Diagram:
```
+-------------+      +--------------+      +------------------+
|  Write .tf  | ---> | terraform    | ---> | terraform apply  |
|  config     |      | plan (review)|      | (provision infra)|
+-------------+      +--------------+      +------------------+
```

---
### 4. Terraform Editions
- **Open Source (Community)** – Free; we use this.
- **Terraform Cloud** – SaaS; remote state & team collaboration.
- **Enterprise** – On‑prem, governance, SSO.

---
### 5. Introduction to Azure
Azure provides:
- Virtual Machines
- Azure Kubernetes Service
- App Service
- Azure SQL
- Storage Accounts

Access methods:
- Azure Portal (UI)
- Azure CLI
- Terraform

---
### 6. Building Your First Terraform Config

Created **main.tf** with provider block:
```
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.4.0"
    }
  }
}

provider "azurerm" {
  features {}
}
```

Provider versions change often → normal.

---
### 7. Authentication & Authorization in Azure
Terraform requires:
- Authentication
- Authorization

Azure Entra ID handles:
- **Authentication** – who are you?
- **Authorization** – what can you do?

Auth Methods:
- Azure CLI Login
- Service Principal (Client ID + Secret)
- Managed Identity (Azure-hosted)

Using Azure CLI for now.

---
### 8. Creating a User for Terraform Deployment
You created a user in **Entra ID → Users**, then logged in via:
- Azure Portal
- Azure CLI (`az login`)

Initial CLI login showed **no subscription** → expected until RBAC assigned.

---
### 9. Azure CLI Setup
You installed Azure CLI and ran:
```
az login
az account show
```
CLI login context is reused by Terraform.

---
### 10. Deploying a Resource Group Using Terraform
Resource Group groups resources.

Diagram:
```
+-----------------------------------------------+
|                Resource Group                 |
|-----------------------------------------------|
|  +------------+   +------------------------+  |
|  |   VM(s)    |   | Storage Account(s)     |  |
|  +------------+   +------------------------+  |
|                                               |
|  +------------+   +------------------------+  |
|  | SQL DB     |   | Virtual Network        |  |
|  +------------+   +------------------------+  |
+-----------------------------------------------+
```

---
### 11. Terraform Resource Block Explained
Resource block format:
```
resource "<TYPE>" "<NAME>" {
  argument = value
}
```
Diagram:
```
resource "azurerm_resource_group" "appgrp" {
# TYPE = Azure resource type
# NAME = Terraform internal reference
  name     = "app-grp"
  location = "North Europe"
}
```

---
### 12. Authentication & Authorization Flow
Diagram:
```
Terraform CLI
     |
     | uses Azure CLI credentials
     v
Azure CLI (az login)
     |
     | token issued by Microsoft Entra ID
     v
Microsoft Entra ID
     |
     | checks RBAC permissions
     v
Azure Subscription
     |
     v
Terraform Allowed to Create Resources
```

---
### 13. Terraform Workflow (Init → Plan → Apply)
Diagram:
```
+---------------------+
|  Write .tf files    |
+----------+----------+
           |
           v
+---------------------+
| terraform init      |
| (download provider) |
+----------+----------+
           |
           v
+---------------------+
| terraform plan      |
| (preview changes)   |
+----------+----------+
           |
           v
+---------------------+
| terraform apply     |
| (create resources)  |
+---------------------+
```

---
### 14. Running Commands
**Init**:
```
terraform init
```
**Plan**:
```
terraform plan -out main.tfplan
```
Plan Diagram:
```
Desired State (main.tf)
        |
        v
+----------------------------+
| terraform plan compares    |
| with existing Azure infra |
+-------------+--------------+
              |
              v
Shows actions needed: + create, ~ update, - destroy
```

**Apply**:
```
terraform apply main.tfplan
```

---
### 15. Understanding New Files Created
Working directory diagram:
```
your-folder/
│
├── main.tf                # your configuration
├── main.tfplan            # binary plan output
├── terraform.tfstate      # tracks deployed resources
├── terraform.tfstate.backup
│
├── .terraform/            # provider plugins
│     └── provider files
│
└── .terraform.lock.hcl    # provider version lock
```

Why state matters:
```
Terraform State
     |
     | maps
     v
Azure Resources
```
Terraform uses state to prevent drift and duplication.

