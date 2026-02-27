
# Azure Networking – Load Balancer & Terraform Modules (Part 1)

## 1. Introduction to Azure Networking Section
In this section, we begin exploring key Azure networking services such as:
- Azure Load Balancer
- Azure Application Gateway
- VNet Peering
- Azure Firewall
- Other network-related components

We also learn how to manage these services using Terraform modules.

---

## 2. Azure Load Balancer – Introduction
The Azure Load Balancer distributes incoming traffic across multiple backend virtual machines.

### Why it is needed:
If an application runs on multiple servers, a load balancer ensures:
- Even request distribution
- High availability
- Better performance under load

---

## 3. Key Components of Azure Load Balancer
### ✔ Frontend IP Configuration
- Public or private entry point for client traffic.
- Typically a public IP for internet-facing load balancers.

### ✔ Backend Pool
- Contains backend VMs (by NIC private IPs).

### ✔ Health Probe
- Used to check availability of backend VMs.
- Sends periodic HTTP/TCP requests.
- Unhealthy VMs are temporarily removed from rotation.

### ✔ Load Balancing Rule
Defines:
- Frontend port → Backend port
- Backend pool
- Probe
- Transport protocol

---

## 4. Manual Setup – Preparing Backend Virtual Machines
Two Ubuntu VMs were deployed. For each VM:
1. SSH connection established using public IP.
2. Installed NGINX web server.
3. Edited `/var/www/html/default.html` to show VM identity.

This simulates each VM hosting part of a web application.

---

## 5. Manual Setup – Creating Azure Load Balancer
### Steps followed:

#### 1. Created Standard Public Load Balancer
- SKU: Standard
- Type: Public
- Region: North Europe

#### 2. Configured Frontend IP
- Created static public IP resource
- Attached to Load Balancer

#### 3. Created Backend Pool
- Added NICs of both VMs

#### 4. Configured Health Probe
- Type: TCP
- Port: 80
- Used to verify NGINX availability

#### 5. Created Load Balancing Rule
- Route: Port 80 frontend → Port 80 backend
- Assigned backend pool + probe

After deployment:
- Accessing the LB public IP alternates traffic between VM1 and VM2.

---

## 6. Moving Toward Terraform Implementation
After understanding the manual steps, the next goal is automating the full setup using Terraform.

But instead of writing a long, flat Terraform file, we begin using **Terraform Modules**.

---

## 7. Terraform Modules – Concept
Modules allow:
- Code reuse
- Cleaner structure
- Separation of concerns
- Repeated deployments across environments

### Types of Modules:
- **Root Module** → main Terraform directory the user runs
- **Child Modules** → reusable components placed in subdirectories

---

## 8. Why Use Modules?
Real environments have repeating patterns such as:
- VNets
- Subnets
- VM clusters
- Load Balancers

Modules help avoid:
- Code duplication
- Hard-to-maintain long files
- Inconsistent resource configurations

---

## 9. Passing Data Between Modules
### Parent → Child
Uses **input variables**:
```hcl
module "network" {
  source = "./modules/network"
  vnet_name = var.vnet_name
}
```

### Child → Parent
Uses **outputs**:
```hcl
output "vnet_id" {
  value = azurerm_virtual_network.main.id
}
```

### Important:
Child modules **cannot** access parent variables directly. All required data must be explicitly passed.

---

## 10. Increasing Complexity
This section will show:
- Multiple module creation
- Different patterns for passing data
- Handling nested data structures

The complexity will gradually increase, but each chapter builds naturally on the previous one.

---
# End of Part 1 Notes
