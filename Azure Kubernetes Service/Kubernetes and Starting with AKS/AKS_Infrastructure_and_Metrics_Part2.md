# AKS Networking Infrastructure – VNet, Subnet, NSG, Route Table (Part 2)

## 4. Virtual Network (VNet) & Subnet in AKS
A Virtual Network is Azure’s private network that hosts all AKS components.

### 4.1 VNet (Layman Terms)
A VNet is like a **private neighborhood** for your AKS cluster.
It has:
- Its own address space
- Subnets
- Custom DNS server support

### 4.2 Subnets
Subnets divide the VNet into smaller blocks.
AKS nodes must live inside a subnet.

Example subnet:
```
10.224.0.0/16
```
Contains 65,536 IPs.

### 4.3 Azure Reserves 5 IPs Per Subnet
Reserved IPs:
- `.0` → Network address
- `.1` → Default gateway
- `.2` & `.3` → Azure DNS mapping
- `.255` → Broadcast

### 4.4 Node IP Assignment
Nodes get IPs from subnet:
```
10.224.0.4
10.224.0.5
10.224.0.6
```

### 4.5 VNet DNS Behavior
CoreDNS forwards external queries to the DNS server defined at VNet level.
If you change VNet DNS settings, you must **restart all VMSS nodes** to apply changes.

---

## 5. Network Security Group (NSG)
NSG filters traffic by source, destination, port, and protocol.

### 5.1 NSG as an Airport Security Checkpoint (Layman Terms)
It checks each packet and decides:
- Allow
- Deny

### 5.2 Default NSG Rules
Azure adds non-removable rules:
- Allow VNet inbound
- Allow AzureLoadBalancer
- Deny all inbound from Internet

### 5.3 Important Warning
Do **NOT** block intra-subnet traffic using NSGs.
Reason:
- Nodes must talk to each other
- Blocking breaks cluster

To control pod traffic, use **Kubernetes Network Policies**, NOT NSGs.

### 5.4 Custom Subnets
NSG customization is allowed if subnet is custom-created.

---

## 6. Route Table in AKS
Route Tables decide how traffic exits a subnet.

### 6.1 Why AKS Uses Route Table
For **kubenet** network plugin:
- Each pod gets an IP from pod CIDR
- Route table maps pod CIDRs → node IPs

### 6.2 Node-Based Pod CIDR Allocation
Example:
```
Node0 handles: 10.244.0.0/24
Node1 handles: 10.244.1.0/24
```
Routes created:
```
10.244.0.0/24 → Node0
10.244.1.0/24 → Node1
```

### 6.3 Demo You Performed
1. Viewed route table
2. Saw automatic routes for each node
3. Verified pod IP patterns correspond to node assignment
4. Confirmed traffic routing matches route table

---

## 7. Final Summary
You explored:
- Metrics Server
- Infrastructure RG
- VM Scale Set
- VNet & Subnet
- Network Security Group
- Route Table behavior

All these components form the **Azure foundation** beneath AKS.

---
