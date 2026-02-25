
# Terraform on Azure – Notes (Set 7)

## 67. Creating NSG Associations Using `for_each`
To dynamically associate an NSG with multiple subnets created via `for_each`, you used a single association block that loops through all subnets. Terraform replaces each iteration with actual subnet keys such as `web-subnet01` and `app-subnet01`.

```hcl
resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  for_each = var.subnet_information

  subnet_id                 = azurerm_subnet.subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.app_nsg.id
}
```

This ensures NSG assignment is scalable, clean, and driven entirely by variable data.

---

## 68. Deploying Multiple Virtual Machines Using `count`
You deployed two Windows VMs (`webvm01` and `webvm02`) using the `count` meta-argument.
Each VM is mapped to its corresponding NIC and Public IP via `count.index`.

```hcl
resource "azurerm_windows_virtual_machine" "webvm" {
  count = var.nic_count

  name = "webvm0${count.index + 1}"

  network_interface_ids = [
    azurerm_network_interface.webnic[count.index].id
  ]
}
```

### Mapping Behavior
| VM | Index | NIC | Public IP |
|----|-------|------|-----------|
| webvm01 | 0 | webnic[0] | webip[0] |
| webvm02 | 1 | webnic[1] | webip[1] |

Terraform keeps all resources aligned using their index.

---

## 69. Availability Sets
Availability Sets increase VM resiliency by distributing VMs across:
- **Fault Domains (FDs)** → Different power/network racks
- **Update Domains (UDs)** → Different maintenance reboot groups

```hcl
resource "azurerm_availability_set" "appset" {
  name                         = "app-avset"
  location                     = local.resource_location
  resource_group_name          = azurerm_resource_group.appgrp.name
  platform_fault_domain_count  = 3
  platform_update_domain_count = 3
}

resource "azurerm_windows_virtual_machine" "webvm" {
  availability_set_id = azurerm_availability_set.appset.id
}
```

Result: VMs are spread across multiple hardware racks and reboot groups.

---

## 70. Availability Zones
Availability Zones provide resiliency across entire **data centers**.
Each Azure region has Zones 1, 2, and 3.

```hcl
resource "azurerm_windows_virtual_machine" "webvm" {
  count = 2
  name  = "webvm0${count.index + 1}"
  zone  = count.index + 1
}
```

Result:
- VM1 → Zone 1
- VM2 → Zone 2

This protects your application from full datacenter outages.

---

## 71. Introduction to Azure Key Vault
Azure Key Vault stores:
- **Secrets** (passwords)
- **Keys** (encryption keys)
- **Certificates** (TLS/SSL certificates)

You created Key Vault via Portal with RBAC access model.

---

## 72. Creating a Key Vault with Terraform
```hcl
resource "azurerm_key_vault" "appvault" {
  name                = "appvault12345"
  location            = local.resource_location
  resource_group_name = azurerm_resource_group.security.name
  tenant_id           = "<tenant-id>"
  sku_name            = "standard"
}
```

Tenant ID is required. RBAC is recommended.

---

## 73. Fetching an Existing Key Vault with Data Source
If Key Vault is already created manually, use:

```hcl
data "azurerm_key_vault" "existing" {
  name                = "app-vault"
  resource_group_name = "security-group"
}
```

This fetches:
- Key Vault ID
- URI
- Access policies

---

## 74. Creating a Secret in Key Vault via Terraform
```hcl
resource "azurerm_key_vault_secret" "vm_password" {
  name         = "vm-password"
  value        = var.admin_password
  key_vault_id = data.azurerm_key_vault.existing.id
}
```

Secret value comes from sensitive variable input.

---

## 75. Using the Key Vault Secret as VM Admin Password
```hcl
admin_password = azurerm_key_vault_secret.vm_password.value
```

### Password Flow Diagram
```
User → terraform.tfvars → var.admin_password
        → Terraform creates secret in Key Vault
        → VM admin_password reads secret.value
```

---

## 76. Required IAM Permissions
Terraform’s service principal was granted:
- **Key Vault Secrets Officer** → can create/manage secrets

Portal admins need:
- Key Vault Administrator OR
- Key Vault Secrets Officer

---

## 77. Full End-to-End Workflow Summary
You deployed:
- VNet
- Subnets from `for_each`
- NSG + dynamic associations
- NICs & Public IPs using `count`
- VMs with availability zones/sets
- Key Vault
- Secret created by Terraform
- VM password pulled securely from secret

This completed a fully automated, secure VM deployment pipeline.

---
