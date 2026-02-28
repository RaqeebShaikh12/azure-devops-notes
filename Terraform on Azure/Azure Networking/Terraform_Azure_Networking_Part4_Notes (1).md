
# Terraform Azure Networking — VNet Peering & Application Gateway (Part 4 Notes)

This part combines **concepts + manual steps + Terraform patterns** for two services:

- **Virtual Network Peering** (connect VNets for private traffic)
- **Azure Application Gateway** (Layer‑7 load balancer with path‑based routing)

---

## 1) Virtual Network Peering — Concept & Why
**VNet peering** connects two Azure VNets so resources in one VNet can **privately** reach resources in the other. Without peering, VNets are isolated and internal private IP connectivity is not possible.

**Typical scenario**: `app-vnet` has VM A; `test-vnet` has VM B. VM A must call VM B via **private IP**. After peering both VNets, the `curl http://<vm-b-private-ip>/...` request from VM A succeeds.

---

## 2) Building Multiple VNets via Modules (for_each at the call site)
Drive multiple VNets from **one input map** and call the VNet module once per key.

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

**Root `main.tf` (call)**
```hcl
module "network" {
  for_each            = var.environment              # keys: app, test
  source              = "./modules/networking/vnet"

  resource_group_name = var.resource_group_name
  location            = var.location

  vnet_name           = each.value.vnet_name
  address_prefix      = each.value.address_space

  subnet_count        = each.value.subnet_count
  public_ip_count     = each.value.public_ip_count
  nic_count           = each.value.nic_count

  resource_prefix     = each.key                     # app → app-subnet-0, app-nic-0, etc.
}
```
> Keep VNet module outputs handy (`vnet_id`, `subnet_ids`, `nic_ids`, `nic_private_ips`) for VMs, peering, and gateways.

---

## 3) Per‑VNet VMs (for_each + prefixes)
```hcl
module "vm" {
  for_each            = var.environment
  source              = "./modules/compute/virtualMachines"

  resource_group_name = var.resource_group_name
  location            = var.location
  vm_count            = each.value.vm_count
  resource_prefix     = each.key  # names like app-vm-01, test-vm-01

  nic_ids             = module.network[each.key].nic_ids
  public_ips          = module.network[each.key].public_ips
}
```

**Provisioner timing tip**: Copying to `/var/www/html` immediately after installing nginx may fail (directory not ready). Prefer **cloud‑init** or **Custom Script Extension**; if you must, add a temporary `time_sleep` to wait before copying.

---

## 4) VNet Peering Module (bidirectional links)
Azure peering requires **two** uni‑directional links:
- `vnetA → vnetB`
- `vnetB → vnetA`

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

**Test**: Before peering, private curl fails; after peering, it succeeds.

---

## 5) Azure Application Gateway — Full Concept & Manual Implementation

### A. What is it?
**Azure Application Gateway** is a **Layer‑7** (Application Layer) load balancer. Unlike the Layer‑4 Azure Load Balancer (TCP/UDP routing), App Gateway understands HTTP/HTTPS and can route based on **URL path, host header, protocol, and cookies**.

### B. Why use it?
- URL‑based routing (e.g., `/images/*` vs `/videos/*`)
- Multi‑site routing (different hostnames)
- End‑to‑end TLS, cookie‑based affinity, session persistence
- Optional **WAF** (Web Application Firewall) SKUs

### C. Core Components
1) **Application Gateway Subnet** — dedicated empty subnet where the gateway’s managed instances run
2) **Frontend IP Configuration** — public or private IP that users connect to
3) **Backend Pool** — VM/VMSS/App Service/IP/FQDN targets
4) **HTTP Settings** — how the gateway talks to backends (port, protocol, affinity)
5) **Listener** — how the gateway listens (frontend IP, port, protocol, optional host)
6) **Rules** — connect listener → backend (basic) or URL‑path based (path map)
7) **Health Probe (optional)** — check backend health

### D. Manual Walkthrough (you demonstrated this end‑to‑end)
1) **Two VMs** prepared with nginx:
   - VM1 → `/videos/default.html`
   - VM2 → `/images/default.html`
2) **Virtual Network** with normal subnets **and** a dedicated empty subnet for the gateway
3) **Create Application Gateway**:
   - SKU: Standard_v2, autoscaling (min 1)
   - **Frontend**: public IP
   - **Backend pools**: `videos-pool` (VM1), `images-pool` (VM2)
   - **HTTP settings**: HTTP/80
   - **Listener**: public HTTP port 80
   - **Rule**: **path‑based** → map
     - `/videos/*` → `videos-pool`
     - `/images/*` → `images-pool`
4) **Test**:
   - `http://<appgw-ip>/videos/default.html` → VM1
   - `http://<appgw-ip>/images/default.html` → VM2

> This confirms URL routing works as expected at Layer‑7.

---

## 6) Deterministic VM Setup with Custom Script Extension (CSE) + Storage Module
To avoid provisioner timing issues and make VM setup repeatable, we used **Custom Script Extension** and hosted scripts in **Azure Storage**.

- Scripts uploaded to container `scripts`:
  - `install_web_images.sh` → creates `/var/www/html/images/default.html`
  - `install_web_videos.sh` → creates `/var/www/html/videos/default.html`
- Storage module creates:
  - Storage account (unique name using `random_integer`)
  - Containers (e.g., `scripts`, `data`)
  - Blobs (uploads scripts)
- VM module installs the CSE referencing the script URIs

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

## 7) Modeling Data — Nested → Flattened → Module Inputs
You modeled the infra as **nested objects** (VNet → Subnets → NICs → VMs) but passed **flat lists/maps** into modules by using `locals` + `flatten()` + `for` expressions:

- VNet details → `[ {vnet_name, address_space}, ... ]`
- Subnets → `[ {subnet_name, vnet_name, subnet_prefix}, ... ]`
- NICs → `[ {nic_name, subnet_name}, ... ]`
- VMs → `[ {vm_name, nic_name, script_name}, ... ]`

Then convert list → map for `for_each`:
```hcl
for_each = { for s in local.subnet_details : s.subnet_name => s }
```
This keeps each module’s inputs **simple and focused**.

---

## 8) Application Gateway Module — Path‑based Routing (Terraform Patterns)
**Inputs** include:
- Gateway details: `[ vnet_name, gateway_subnet_name, gateway_subnet_prefix ]`
- NIC details (so we can look up private IPs via data sources)
- Pool details (map): which NIC belongs to which pool (images/videos)

**Dynamic pools (sketch)**
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

**Validation**: hitting both paths returns content from the correct backend VM.

---

## 9) Build Order & Dependencies
Recommended order:
1. **Storage** (upload scripts)
2. **VNet** (subnets, NICs)
3. **VMs** (CSE needs scripts + NICs)
4. **Application Gateway** (needs NIC private IPs)

Prefer output references to let Terraform infer dependencies; use `depends_on` only when necessary.

---

## 10) Recap
- Built multiple VNets using `for_each` **at the module call**
- Deployed VMs per VNet; explained why **CSE/cloud‑init** beats provisioners
- Implemented **VNet Peering** with a tiny, focused module
- Introduced a **Storage** module and **random_integer** for unique names
- Modeled nested inputs → **flattened** per‑module inputs for clarity
- Deployed **Application Gateway** with **path‑based routing** and validated traffic to the right backends

---
