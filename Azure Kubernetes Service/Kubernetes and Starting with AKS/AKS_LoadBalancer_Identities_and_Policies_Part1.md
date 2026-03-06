# AKS Load Balancer, Public IPs & Managed Identities – Detailed Notes (Part 1)

## 1. Azure Load Balancer & Public IP – Detailed Notes
Azure Load Balancer operates at Layer 4 of the OSI model and is used heavily in AKS.
It comes in two types:
- Public Load Balancer
- Internal Load Balancer

Tiers:
- Basic (free, no SLA)
- Standard (recommended, SLA-based)

### 1.1 What Azure Load Balancer Does in AKS
Azure Load Balancer has two key roles:

#### A) Provides Outbound Connectivity for Nodes
Nodes inside VNets need outbound internet access:
- Pulling images
- Accessing APIs
- Downloading updates

This is handled using a **Public IP** attached to the Load Balancer.
Nodes use this public IP through **SNAT (Source NAT)**.

#### B) Exposes Applications via Kubernetes Service Type LoadBalancer
When you run:
```
kubectl expose deploy myapp --type LoadBalancer --port 80
```
AKS automatically:
- Updates Azure Load Balancer
- Creates a public IP
- Creates LB rule
- Creates health probe
- Maps backend pool to VM nodes

### 1.2 Public IP (Layman Explanation)
A **public IP** is:
- Internet-reachable
- Unique globally
- Assigned to the front-end of an Azure Load Balancer

### 1.3 Load Balancer Components
#### Frontend IP Configuration
The public IP users connect to.

#### Backend Pool
Contains VMSS nodes:
```
node0, node1, node2
```

#### Health Probes
Continuously check if a backend instance is healthy.

#### Load Balancer Rules
Defines:
- Frontend IP
- Frontend port
- Backend port

#### Outbound Rules
Enable Internet access for nodes.

### 1.4 Demonstration Summary
1. Viewed Azure LB “kubernetes”
2. Saw frontend IP and backend pool
3. Created Service → Azure provisioned new public IP
4. Saw automatic creation of:
   - Health probe
   - Load balancing rule (port 80)
   - NSG rule allowing port 80 inbound
5. Application reachable via internet

---

## 2. Managed Identities in AKS – Deep Explanation
Azure Managed Identity allows Azure resources to authenticate without storing secrets.
Two types:
- System Assigned Identity
- User Assigned Identity

### 2.1 System Assigned
- Automatically created with AKS
- Tied to AKS control plane
- Used to manage Azure resources such as:
  - LB
  - Public IP
  - VMSS
  - Route Table

### 2.2 User Assigned (Kubelet Identity)
- Found in Infra Resource Group
- Name format: `<clustername>-agentpool`
- Used to authenticate nodes to Azure Container Registry
- Independent lifecycle

### 2.3 Identity Visibility
- Kubelet identity → User Assigned in Infra RG
- Control plane identity → System Assigned in role assignments

---

## 3. Virtual Network (VNet) & Subnet – Important Concepts
A Virtual Network is Azure’s private network hosting AKS.
Subnets divide the VNet.

### 3.1 Reserved IPs (5 per subnet)
- .0 → Network address
- .1 → Default gateway
- .2, .3 → Azure DNS mapping
- .255 → Broadcast

### 3.2 DNS Behavior
CoreDNS forwards external queries to VNet DNS servers.
Changing DNS requires restarting nodes.

---

## 4. Network Security Group (NSG) in AKS
NSG filters inbound/outbound traffic.

### 4.1 Important Warning
❌ **Never block intra-subnet traffic**.
This breaks Kubernetes and is unsupported.

### 4.2 Use Network Policies for Pod-Level Control
NSGs control node traffic.
Network Policies control pod traffic.

---
