
# Terraform on Azure – Notes (Set 6)

## 61. The `count` Meta‑Argument in Terraform
Terraform’s `count` meta‑argument allows you to create **multiple instances of the same resource type** using a single resource block.

### Why Use `count`?
Without `count`, to create 3 storage accounts you’d need:
```hcl
resource "azurerm_storage_account" "sa1" { /* ... */ }
resource "azurerm_storage_account" "sa2" { /* ... */ }
resource "azurerm_storage_account" "sa3" { /* ... */ }
```
With `count`:
```hcl
resource "azurerm_storage_account" "storage" {
  count = 3
  # common configuration here
}
```
Terraform creates 3 instances automatically.

### Dynamic Naming With `count`
Storage accounts require **globally unique names**. Use `count.index` (0‑based) to generate unique names:
```hcl
resource "azurerm_storage_account" "appsa" {
  count = 3
  name  = "appstor${count.index}"
  resource_group_name      = azurerm_resource_group.appgrp.name
  location                 = "North Europe"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```
Creates: `appstor0`, `appstor1`, `appstor2`.

### Correct Dependency Referencing
Always reference the resource group object to enforce ordering:
```hcl
resource_group_name = azurerm_resource_group.appgrp.name
```

### State Representation
Counted instances appear as:
```
azurerm_storage_account.appsa[0]
azurerm_storage_account.appsa[1]
azurerm_storage_account.appsa[2]
```
Each has its own attributes tracked by index.

---

## 62. The `for_each` Meta‑Argument
Use `for_each` when instances differ (names/attributes) and you want key‑based addressing.

### Using `for_each` With a Set
Create three containers named `data`, `scripts`, and `logs`:
```hcl
resource "azurerm_storage_container" "containers" {
  for_each = toset(["data", "scripts", "logs"])  # convert list → set
  name                  = each.key
  storage_account_name  = azurerm_storage_account.appsa[0].name
}
```
State keys become:
```
containers["data"], containers["scripts"], containers["logs"]
```

---

## 63. `for_each` With Maps (Uploading Multiple Blobs)
Map lets you use **name/value pairs**:
```hcl
resource "azurerm_storage_blob" "script_blobs" {
  for_each = {
    script1 = "script01.ps1"
    script2 = "script02.ps1"
    script3 = "script03.ps1"
  }
  name                   = each.key
  source                 = each.value
  storage_account_name   = azurerm_storage_account.appsa[0].name
  storage_container_name = azurerm_storage_container.containers["scripts"].name
  type                   = "Block"
}
```
Creates three blobs using their mapped file names.

---

## 64. Using `for_each` to Create Multiple Subnets
Define a map of subnet names → CIDRs and iterate:
```hcl
variable "subnet_information" {
  type = map(object({ cidr_block = string }))
}

# terraform.tfvars
# subnet_information = {
#   "web-subnet01" = { cidr_block = "10.0.0.0/24" }
#   "app-subnet01" = { cidr_block = "10.0.1.0/24" }
# }

resource "azurerm_subnet" "subnets" {
  for_each = var.subnet_information
  name                 = each.key
  resource_group_name  = azurerm_resource_group.appgrp.name
  virtual_network_name = azurerm_virtual_network.appnetwork.name
  address_prefixes     = [each.value.cidr_block]
}
```

---

## 65. Creating Multiple Public IPs Using `count` and Mapping to NICs
Use a numeric variable for how many NICs you want:
```hcl
variable "nic_count" {
  type    = number
  default = 2
}

resource "azurerm_public_ip" "webip" {
  count = var.nic_count
  name  = "webip-${count.index + 1}"
  location            = local.resource_location
  resource_group_name = azurerm_resource_group.appgrp.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "webnic" {
  count               = var.nic_count
  name                = "web-interface-0${count.index + 1}"
  location            = local.resource_location
  resource_group_name = azurerm_resource_group.appgrp.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnets["web-subnet01"].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.webip[count.index].id
  }
}
```
This pairs NIC `web-interface-01` with `webip-1`, and `web-interface-02` with `webip-2`.

---

## 66. Driving Subnets From Variables (Object Maps)
Move subnet definitions into variables for a data‑driven design:

```hcl
variable "subnet_information" {
  type = map(object({ cidr_block = string }))
}

# terraform.tfvars
# subnet_information = {
#   "web-subnet01" = { cidr_block = "10.0.0.0/24" }
#   "app-subnet01" = { cidr_block = "10.0.1.0/24" }
# }

resource "azurerm_subnet" "subnets" {
  for_each             = var.subnet_information
  name                 = each.key
  resource_group_name  = azurerm_resource_group.appgrp.name
  virtual_network_name = azurerm_virtual_network.appnetwork.name
  address_prefixes     = [each.value.cidr_block]
}
```

**Benefits**
- No hardcoding
- Easy to extend to more subnets
- Clean separation of structure (code) and data (vars)

---

**End of Set 6 notes.**
