
# Terraform Azure Networking — VNet Peering & Application Gateway (Part 4 Notes)

## 1) Virtual Network Peering — What & Why
**VNet peering** connects **two Azure VNets** so resources in one can privately reach resources in the other. Without peering, VNets are **isolated**. With peering, private IP traffic flows across VNets with low latency and high bandwidth.

---

## 2) Multi‑VNet via Modules (for_each at the module call)
Drive multiple VNets from a single variable and call the **VNet module** once per environment key.

**Root `variables.tf`**
```hcl
variable "environment" {
  type = map(object({
    vnet_name       = string
    address_space   = string
    subnet_count    = number
    nic_count       = number
    public_ip_count = number
    vm_count        = number
  }))
}
```

**Example `terraform.tfvars`**
```hcl
environment = {
  app = {
    vnet_name       = "app-vnet"
    address_space   = "10.0.0.0/16"
    subnet_count    = 2
    nic_count       = 2
    public_ip_count = 2
    vm_count        = 1
  }
  test = {
    vnet_name       = "test-vnet"
    address_space   = "10.1.0.0/16"
    subnet_count    = 2
    nic_count       = 2
    public_ip_count = 2
    vm_count        = 1
  }
}
```

**Root `main.tf` (calling the VNet module)**
```hcl
module "network" {
  for_each            = var.environment
  source              = "./modules/networking/vnet"

  resource_group_name = var.resource_group_name
  location            = var.location

  vnet_name           = each.value.vnet_name
  address_prefix      = each.value.address_space

  subnet_count        = each.value.subnet_count
  public_ip_count     = each.value.public_ip_count
  nic_count           = each.value.nic_count

  resource_prefix     = each.key
}
```

> Keep module outputs (e.g., `vnet_id`, `subnet_ids`, `nic_ids`, `nic_private_ips`) for reuse by VM & peering modules.

---

## 3) Per‑VNet VMs (for_each at call site + prefixes)
```hcl
module "vm" {
  for_each            = var.environment
  source              = "./modules/compute/virtualMachines"

  resource_group_name = var.resource_group_name
  location            = var.location
  vm_count            = each.value.vm_count
  resource_prefix     = each.key  # e.g., app-vm-01, test-vm-01

  nic_ids             = module.network[each.key].nic_ids
  public_ips          = module.network[each.key].public_ips
}
```

### Provisioner timing note
Copying to `/var/www/html` right after installing **nginx** may fail intermittently. Prefer **cloud-init** or **Custom Script Extension** instead of `file`/`remote-exec`. If you must, insert a temporary wait using `time_sleep`.

---

## 4) VNet Peering Module (bidirectional)
Azure requires **two links**: `vnetA → vnetB` and `vnetB → vnetA`.

**Peering resource**
```hcl
resource "azurerm_virtual_network_peering" "peer" {
  name                         = "${var.source_vnet_name}-to-${var.dest_vnet_name}"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = var.source_vnet_name
  remote_virtual_network_id    = var.dest_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}
```

**Driving map in root**
```hcl
variable "peering_pairs" {
  type = map(object({ dest_vnet_name = string, dest_vnet_key = string }))
}
```

**Root call**
```hcl
module "vnet_peering" {
  for_each            = var.peering_pairs
  source              = "./modules/networking/vnetPeering"

  resource_group_name = var.resource_group_name
  source_vnet_name    = module.network[each.key].vnet_name
  dest_vnet_name      = each.value.dest_vnet_name
  dest_vnet_id        = module.network[each.value.dest_vnet_key].vnet_id
}
```

**Test:** Before peering, `curl http://<other-vnet-private-ip>/...` fails; after peering, it succeeds.

---

## 5) Azure Application Gateway — Overview
Layer‑7 load balancer that routes based on HTTP attributes (host/path).
- Requires **dedicated empty subnet**
- Components: Frontend IP, Listeners, Backend Pools, HTTP Settings, (optional) Probes, Rules
- Use **path‑based routing**: `/videos/*` → videos VM, `/images/*` → images VM

---

## 6) Deterministic VM Setup with Custom Script Extension (CSE) + Storage Module
**Scripts** (uploaded to Storage → container `scripts`):
- `install_web_images.sh` → creates `/var/www/html/images/default.html`
- `install_web_videos.sh` → creates `/var/www/html/videos/default.html`

**Storage module** creates:
- Storage account (unique name via `random_integer`)
- Containers (e.g., `scripts`, `data`)
- Blobs (uploaded scripts)

**CSE example**
```hcl
resource "azurerm_virtual_machine_extension" "cse" {
  for_each             = { for vm in var.vm_details : vm.vm_name => vm }
  name                 = "cse-${each.key}"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm[each.key].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"
  settings = jsonencode({
    fileUris         = ["https://${var.storage_account_name}.blob.core.windows.net/${var.container_name}/${each.value.script_name}"]
    commandToExecute = "bash ${each.value.script_name}"
  })
}
```

---

## 7) Nested → Flattened → Per‑module Inputs
Model infra as nested objects, then **flatten** with `locals` + `flatten()` + `for` expressions into simple lists/maps:
- VNet details: `[ {vnet_name, address_space}, ... ]`
- Subnets: `[ {subnet_name, vnet_name, subnet_prefix}, ... ]`
- NICs: `[ {nic_name, subnet_name}, ... ]`
- VMs: `[ {vm_name, nic_name, script_name}, ... ]`

Convert list → map for `for_each`:
```hcl
for_each = { for s in local.subnet_details : s.subnet_name => s }
```

---

## 8) Application Gateway Module (path‑based routing)
Inputs:
- **Gateway details**: `[ vnet_name, gateway_subnet_name, gateway_subnet_prefix ]`
- **NIC details**: to look up backend NICs via data sources
- **Pool details** (map): which NIC goes to which pool (images/videos)

**Dynamic backend pools (sketch)**
```hcl
data "azurerm_network_interface" "nic" {
  for_each            = { for n in var.nic_details : n.nic_name => n }
  name                = each.key
  resource_group_name = var.resource_group_name
}

dynamic "backend_address_pool" {
  for_each = var.pool_details
  content {
    name = "${backend_address_pool.key}-pool"
    backend_addresses = [{
      ip_address = data.azurerm_network_interface.nic[backend_address_pool.value.nic_name].ip_configuration[0].private_ip_address
    }]
  }
}
```

**URL path map**
- `/videos/*` → videos pool
- `/images/*` → images pool

Validate by hitting `http://<appgw-public-ip>/videos/default.html` and `/images/default.html`.

---

## 9) Order & Dependencies
Recommended order:
1. **Storage** (scripts)
2. **VNet** (subnets, NICs)
3. **VMs** (CSE requires scripts + NICs)
4. **Application Gateway** (needs NIC private IPs)

Prefer output references over `depends_on` where possible.

---

## 10) Recap
- Built **multiple VNets** by applying `for_each` at the module call
- Created **VMs per VNet**, highlighted provisioner timing and why CSE/cloud‑init is better
- Implemented **VNet peering** with a simple peering module
- Introduced a **Storage** module to host bootstrapping scripts
- Modeled data as nested → **flattened** → per‑module inputs
- Deployed **Application Gateway** with **path‑based routing** to the right backend VMs

---
