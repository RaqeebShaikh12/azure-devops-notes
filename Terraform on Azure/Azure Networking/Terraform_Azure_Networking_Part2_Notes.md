
# Terraform Azure Networking – Modules & Load Balancer (Part 2 Notes)

## 1. Introduction to Terraform Modules
Modules help:
- Reuse infrastructure code
- Organize deployments
- Simplify complex environments
- Separate concerns (networking, compute, etc.)

Each module typically contains:
- `main.tf` → core resources
- `variables.tf` → input variables
- `outputs.tf` → exported values

Modules cannot access parent variables directly. Data must be passed explicitly.

---

## 2. Building the Resource Group Module
Folder structure:
```
modules/
  general/
    resourceGroup/
      main.tf
      variables.tf
      outputs.tf
```

`main.tf` defines:
- Resource group creation

`variables.tf` defines:
- `resource_group_name`
- `location`

Root module calls it via:
```hcl
module "resource_group" {
  source              = "./modules/general/resourceGroup"
  resource_group_name = var.resource_group_name
  location            = var.location
}
```

---

## 3. Building the Virtual Network Module
Folder:
```
modules/networking/vnet/
```
Files:
- `main.tf` → VNet + subnets
- `variables.tf`
- `outputs.tf`

### Subnets Using `count` + `cidrsubnet()`
```hcl
resource "azurerm_subnet" "subnets" {
  count                = var.subnet_count
  name                 = "subnet-${count.index}"
  address_prefixes     = [cidrsubnet(var.address_prefix, 8, count.index)]
  virtual_network_name = var.vnet_name
}
```

### Why `cidrsubnet()`?
Allows automatic subnet creation like:
- 10.0.0.0/24
- 10.0.1.0/24
- etc.

---

## 4. Adding Public IPs & Network Interfaces in VNet Module
Two new resources:
- `azurerm_public_ip`
- `azurerm_network_interface`

Both use `count` to create multiple NICs + Public IPs.

NICs are attached to subnets using:
```hcl
subnet_id = azurerm_subnet.subnets[count.index].id
```

Public IPs referenced similarly.

### Outputs Added
- NIC IDs list
- NIC private IPs list
- Public IPs list
- Virtual Network ID

---

## 5. Creating the Compute Module (Virtual Machines)
Folder:
```
modules/compute/virtualMachines/
```
Files:
- `main.tf`
- `variables.tf`
- `outputs.tf`

### VM Creation
Using:
- `count` for multiple VMs
- Cloud-init to install nginx
- NIC IDs passed from VNet module

Example:
```hcl
network_interface_ids = [var.nic_ids[count.index]]
```

Cloud-init file used to auto-install packages.

---

## 6. Passing Output From VNet Module → VM Module
VNet module outputs NIC IDs and Public IPs.
VM module consumes them via variables:
```hcl
nic_ids = module.networking.nic_ids
public_ips = module.networking.public_ips
```

### This is the core idea of module communication.

---

## 7. Copying Files to VMs Using `null_resource` + `file` Provisioner
A dynamic HTML file is copied to each VM using:
- `count`
- `file` provisioner
- Inline generation of HTML content

Example content:
```html
<h1>This is web server ${module.vm[count.index].name}</h1>
```

SSH connection uses:
```hcl
host     = var.public_ips[count.index]
user     = "azureuser"
password = "Azure@123"
```

---

## 8. Creating the Load Balancer Module
Folder:
```
modules/networking/loadBalancer/
```
Files:
- `main.tf`
- `variables.tf`
- `outputs.tf`

### Resources Inside LB Module:
1. Public IP for LB frontend
2. Load balancer itself
3. Backend address pool
4. Health probe (port 80)
5. LB rule (port 80 → 80)
6. Backend pool NIC attachment using dynamic IP list

Example:
```hcl
backend_address_pool {
  name = "backendPool"
}
```

Backend association uses: 
```hcl
private_ip_address = var.nic_private_ips[count.index]
```

---

## 9. Root Module Wiring
Root module integrates everything:

```hcl
module "resource_group" {}
module "networking" {}
module "vm" {}
module "loadbalancer" {}
```

Order enforced via:
```hcl
depends_on = [module.resource_group]
```

LB receives:
- VNet ID
- Private IPs
- VM count

VM module receives:
- NIC IDs
- Public IPs

---

## 10. Final Result
Terraform successfully deployed:
- Resource Group module
- VNet module
- Public IPs + NICs
- NSG + Subnet associations
- VM module (nginx installed, HTML page copied)
- Load Balancer module (probe + rules + backend pool)

Final output:
- Load balancer public IP serves traffic from both VMs
- Traffic alternates between VM1 and VM2
- Entire infra fully modular & reusable

---
# End of Part 2 Notes
