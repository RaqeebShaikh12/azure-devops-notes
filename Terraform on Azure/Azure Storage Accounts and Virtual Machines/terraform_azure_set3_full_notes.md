
# Terraform on Azure – Dependency, Referencing & Virtual Network Notes (Set 3)

## 26. Referencing Terraform Managed Resources
Terraform allows referencing resources instead of hard‑coding values. This ensures:
- No hardcoded names
- Reduced risk of mistakes
- Automatic dependency detection
- Correct resource creation order

### How Referencing Works
Format:
```
<resource_type>.<local_name>.<property>
```

Example (Resource Group name):
```
resource_group_name = azurerm_resource_group.appgrp.name
```

Example (Storage Account name):
```
storage_account_name = azurerm_storage_account.appstorage.name
```

### Diagram: How Terraform Resources Reference Each Other
```
main.tf
│
├── resource "azurerm_resource_group" "appgrp"
│          └── name = "app-grp"
│
├── resource "azurerm_storage_account" "appstorage"
│          └── resource_group_name = appgrp.name ← reference
│
└── resource "azurerm_storage_container" "scripts"
           └── storage_account_name = appstorage.name ← reference
```
Terraform builds a dependency tree automatically.

---
## 27. Why Two Names? (Block Name vs Actual Azure Name)
```
resource "azurerm_resource_group" "appgrp" {
  name = "app-grp"
}
```

| Component  | Meaning |
|------------|---------|
| `appgrp`   | Terraform internal label (used for referencing) |
| `app-grp`  | Actual Azure Resource Group name |

---
## 28. Behaviour After Converting to References
After switching from hardcoding to references:
```
terraform plan
```
Result:
```
No changes. Your infrastructure matches the configuration.
```
Expected because:
- You changed only Terraform syntax
- Cloud infra unchanged
- State file already tracks resources

---
## 29. Terraform Destroy Command
Deletes **all** Terraform‑managed resources.
```
terraform destroy
```
Steps:
1. Refresh state
2. Display destruction plan
3. Ask for confirmation
4. Delete resources

### Diagram: Destroy Lifecycle
```
Terraform State
      |
      v
Destroy Plan
      |
      v
terraform destroy
      |
      v
Azure Infrastructure Deleted
```
Resources deleted:
- Resource group
- Storage account
- Container
- Blob

Docs: https://developer.hashicorp.com/terraform/cli/commands/destroy

---
## 30. Best Practice — DO NOT Modify Terraform‑Managed Resources Manually
Avoid using:
- Azure Portal
- Azure CLI
- Azure PowerShell

Terraform is the **single source of truth**. Manual changes cause:
- Drift
- Re‑creation of deleted objects
- Confusion in state

---
## 31. Understanding `depends_on` in Terraform
Terraform normally infers dependencies via references.
Example: container references storage account → correct order.

### When Auto‑Dependency Does NOT Work
```
resource "my_resource_a" "A" {}
resource "my_resource_b" "B" {}
```
No relationship → Terraform won’t know the order.

### Using `depends_on`
```
resource "azurerm_storage_container" "scripts" {
  name                  = "scripts"
  storage_account_name  = azurerm_storage_account.appstorage.name

  depends_on = [
    azurerm_storage_account.appstorage
  ]
}
```
### Diagram: depends_on Forces Ordering
```
┌──────────────────────┐
│ Storage Account      │
└──────────┬───────────┘
           |
           | depends_on
           v
┌──────────────────────┐
│ Storage Container    │
└──────────────────────┘
```

### Recommendation
- Use **references** (preferred)
- Use `depends_on` **only when no reference exists**

Docs: https://developer.hashicorp.com/terraform/language/meta-arguments/depends_on

---
## 33. Introduction to Building Azure Virtual Machines (VMs)
Azure VMs require many dependent resources.

### Diagram: VM & Its Dependencies
```
+-----------------------------+
|        Azure VM             |
+-----------------------------+
        |        |       |
        v        v       v
  Network NIC   Disk   Public IP
        |
        v
  Virtual Network
        |
        v
       Subnet
        |
        v
Network Security Group (NSG)
```

### Required Components
- **Virtual Network (VNet)** – isolated network
- **Subnet** – segment inside VNet
- **NIC** – attaches VM to the network
- **Public IP** – enables external access
- **OS Disk** – boot disk
- **NSG** – firewall

---
## 34. Manual VM Creation (What Happens in Azure Portal)
Steps:
1. Create Resource Group
2. Choose VM name & region
3. Select OS Image (Windows/Linux)
4. Choose VM size (CPU/RAM)
5. Provide admin username/password
6. (Optional) Add data disks
7. Configure VNet & Subnet
8. Assign/create Public IP
9. Auto-create NIC
10. Auto-create NSG
11. Deploy VM

After deployment:
- Windows → connect using **RDP**
- Linux → connect using **SSH**

---
## 35. Simple Explanation of Virtual Networks
Azure VNet works like a private network.

### Diagram: Simple View
```
Laptop ---- Internet ----> Public IP ----> Azure VM (inside VNet)
                                         |
                                         v
                                      Subnet
```

Analogy:
- **VNet = whole building**
- **Subnet = room inside the building**

Notes:
- VNet contains many subnets
- Subnets contain NICs, VMs
- NSG controls allow/deny rules

---
## 36. Building VNet Using Terraform
```
resource "azurerm_virtual_network" "appnetwork" {
  name                = "app-network"
  location            = local.resource_location
  resource_group_name = azurerm_resource_group.appgrp.name
  address_space       = ["10.0.0.0/16"]

  subnet {
    name           = "appsubnet01"
    address_prefix = "10.0.0.0/24"
  }

  subnet {
    name           = "appsubnet02"
    address_prefix = "10.0.1.0/24"
  }
}
```
Created:
- 1 VNet
- 2 Subnets

Commands:
```
terraform init -upgrade
terraform plan
terraform apply
```
Result: VNet successfully deployed.

---
## 37. Local Values (locals)
Used to avoid repeating values.
```
locals {
  resource_location = "North Europe"
}
```
Use:
```
location = local.resource_location
```

### Diagram
```
Without locals:
  location = "North Europe"
  location = "North Europe"
  location = "North Europe"

With locals:
  location = local.resource_location
``` 

---
## 38. Types of Local Values
Terraform value types:
- string
- number
- bool
- list
- set
- map
- object

Docs: https://developer.hashicorp.com/terraform/language/values/locals

---
## 39. Splitting Terraform Into Multiple Files
Terraform loads all `.tf` files automatically.

Example structure:
```
main.tf        → resource blocks
locals.tf      → local values
terraform.tf   → provider configuration
```

Improves readability & maintenance.

---
## 40. Using a List in Local Values
```
locals {
  subnet_address_prefix = [
    "10.0.0.0/24",
    "10.0.1.0/24"
  ]
}
```
Access by index:
```
local.subnet_address_prefix[0]
local.subnet_address_prefix[1]
```

### Diagram
```
index:   0                1
value: "10.0.0.0/24"   "10.0.1.0/24"
```

---
## 41. Using a Map (Object) in Local Values
```
locals {
  virtual_network = {
    name           = "app-network"
    address_prefix = "10.0.0.0/16"
  }
}
```
Access:
```
name          = local.virtual_network.name
address_space = [local.virtual_network.address_prefix]
```

### Diagram
```
local.virtual_network = {
   name = "app-network"
   address_prefix = "10.0.0.0/16"
}
```

Maps help group related settings.

