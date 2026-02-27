
# Terraform Azure Networking – Virtual Machine Scale Sets & Traffic Manager (Part 3 Notes)

## 1. Azure Virtual Machine Scale Sets (VMSS) — Introduction
Azure VM Scale Sets allow deployment and automatic management of a group of identical virtual machines.
These VMs can scale **out** (increase count) and **in** (decrease count) based on load.

### Why VM Scale Sets?
- Automatically scale based on demand
- Identical, managed VM instances
- Integrates seamlessly with Azure Load Balancer
- Eliminates manual VM provisioning
- Improves resiliency and performance

Earlier, we manually deployed VMs behind a Load Balancer. VMSS is a more dynamic alternative.

---

## 2. Manual Deployment of a VM Scale Set
Steps performed:
1. Create a Resource Group
2. Create a VM Scale Set
3. Choose **Uniform** orchestration mode
4. Initial capacity (e.g., 2 machines)
5. Select image (Ubuntu)
6. Configure networking (new VNet + subnet)
7. Complete deployment

Once deployed:
- Instances appear **inside** the scale set
- They do not appear under individual VM listings

---

## 3. Terraform Module for VM Scale Sets
Created folder structure:
```
modules/
  compute/
    scaleSets/
      main.tf
      variables.tf
      outputs.tf
      cloud-init.yml
```

### Key capabilities in the module:
- `azurerm_linux_virtual_machine_scale_set` resource
- Cloud-init installs nginx
- Receives subnet ID from VNet module
- Receives LB backend pool ID when attaching to LB
- VM instance count controlled via variable

Cloud-init sample:
```yaml
#cloud-config
package_update: true
packages:
  - nginx
```

---

## 4. Subnet Integration via Module Outputs
To place VMSS instances inside the VNet, a subnet ID is required.

VNet module outputs:
```hcl
output "subnet_ids" {
  value = azurerm_subnet.subnets[*].id
}
```

VMSS module consumes:
```hcl
subnet_id = var.subnet_ids[0]
```

---

## 5. Integrating VM Scale Sets with Load Balancer
Load Balancer module outputs backend pool ID:
```hcl
output "vm_pool_id" {
  value = azurerm_lb_backend_address_pool.vm_pool.id
}
```

VMSS module receives it:
```hcl
backend_address_pool_ids = [var.vm_pool_id]
```

VMSS instances automatically join the LB backend pool.

---

## 6. NGINX + HTML Deployment on Each Scale Set VM
Using `null_resource` + `file` provisioner:
- Generate HTML file dynamically
- Copy HTML to each VMSS instance via SSH

Inline HTML example:
```html
<h1>This is web server VM instance</h1>
```

SSH uses VMSS-assigned public IPs.

---

## 7. Azure Traffic Manager — Introduction
Azure Traffic Manager is a **DNS-based global load balancer**.

### Why Traffic Manager?
- Provides global resiliency
- Routes traffic across regions
- Uses DNS responses, not packet forwarding
- Supports multiple routing methods:
  - Priority
  - Weighted
  - Performance
  - Geographic

### Priority Routing Example
- Primary web app (North Europe) → Priority 1
- Secondary web app (UK South) → Priority 2
- Traffic Manager sends 100% traffic to primary
- If primary is unhealthy, switch to secondary

---

## 8. Manual Deployment of Web Apps for Traffic Manager
Two Azure Web Apps deployed:
- Primary (North Europe)
- Secondary (UK South)

Each had a `default.html` page:
- Primary → "This is the primary web application"
- Secondary → "This is the secondary web application"

Then:
- Traffic Manager profile created (priority routing)
- HTTPS probe (port 443)
- Endpoints added with priorities
- Custom host header mapping applied

After stopping primary app → TM correctly routed to secondary.

---

## 9. Web App Deployment via Terraform Module
Created module:
```
modules/app/webApp/
```

### Input structure (map of objects):
```hcl
webapp_environment = {
  primaryPlan = {
    os_type     = "Windows"
    sku         = "S1"
    location    = "northeurope"
    webapp_name = "primaryapp"
  }
  secondaryPlan = {
    os_type     = "Windows"
    sku         = "S1"
    location    = "uksouth"
    webapp_name = "secondaryapp"
  }
}
```

Module outputs:
- `webapp_ids` (list of IDs)
- `webapp_hostnames` (list of default hostnames)

---

## 10. Deploying Traffic Manager via Terraform
New module:
```
modules/networking/trafficManager/
```
### Contains:
- Profile resource
- Endpoints resource (using `for_each`)
- Variables for weight, priority, webapp IDs
- Output for profile DNS name

### Endpoint mapping challenge
Traffic Manager needed:
- ID of each Web App
- Hostname of each Web App

The module attempted to map Web Apps to endpoints using:
```hcl
index = each.value.priority - 1
```
This was functional but **not optimal** because:
- `webapp_ids` array ordering didn’t match priority ordering
- Primary endpoint accidentally pointed to secondary Web App

This was intentional for demonstration — a later chapter will show a cleaner technique.

---

## 11. Terraform Destroy Issues with Traffic Manager
Destroying Traffic Manager failed due to:
- Azure Web App automatically binding custom hostnames created by Traffic Manager
- Terraform not having permission to remove those bindings

### Manual Fix Steps:
1. Disable endpoints in Traffic Manager
2. Delete endpoints
3. Confirm custom hostnames removed from Web Apps
4. Delete resource group successfully

This is a known Azure platform behavior.

---
# End of Part 3 Notes
