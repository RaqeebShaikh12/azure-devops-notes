# Azure AKS Networking — Azure CNI Overlay + Bring Your Own VNet/Subnet/NSG/Route Table

---
# PART 1 — Azure CNI Overlay (Detailed Notes)

## 1. Why Azure CNI Overlay Exists
Traditional Azure CNI assigns VNet IPs to every pod, resulting in higher VNet IP consumption and potential address exhaustion.
Azure CNI Overlay solves this by assigning pod IPs from a separate internal Pod CIDR, not from the VNet.

---
## 2. How Azure CNI Overlay Works
### Pod IPs from Separate Pod CIDR
- Pods receive IPs from a logical overlay network.
- Nodes still receive VNet IPs.

### Overlay Network for Pod-to-Pod
- Azure creates an overlay routing domain.
- No UDRs or encapsulation required.
- Pod-to-pod traffic is routed efficiently inside Azure's networking stack.

### NAT for External Communication
- Pod → Node → NAT → External target
- Node IP becomes the source IP visible outside the cluster.

---
## 3. /24 Allocation Per Node
Each node receives a /24 block for dynamic pod assignment, enabling predictable scaling.

---
## 4. AKS Cluster Creation Command
```
az aks create \
  -g <resource-group> \
  -n <cluster-name> \
  --network-plugin azure \
  --network-plugin-mode overlay \
  --node-count 2
```

---
## 5. Portal Verification
- Only node IPs appear in VNet connected devices.
- Pod IPs appear in node ARP tables.

---
## 6. Advantages
- Conserves VNet IPs.
- Great for internal pod-to-pod traffic.
- Supports up to 1000+ nodes.
- No UDRs required.

---
## 7. Disadvantages
- NAT overhead for outbound traffic.
- No AGIC, no Virtual Nodes.
- Windows Server 2022 only.

---
## 8. Comparison Table
| Feature | Kubenet | Azure CNI | Azure CNI Overlay |
|--------|---------|-----------|-------------------|
| Pod IPs from | Pod CIDR | VNet | Pod CIDR |
| Uses VNet IPs | No | Yes | No |
| Best for | Internal | External | Large/internal clusters |
| Node limit | 400 | 1000-5000 | 1000-5000 |
| UDR needed | Yes | No | No |
| Windows support | None | Full | 2022 only |
| AGIC | Yes | Yes | No |

---
## 9. Other Plugins
- Azure CNI variants
- Azure CNI powered by Cilium
- Bring Your Own CNI

---
# PART 2 — Bring Your Own VNet/Subnet/NSG/Route Table (Detailed Notes)

## 1. Overview
When you bring your own networking components, AKS still manages certain required rules but allows customization.

---
# Terminology
## VNet (Virtual Network)
A private network boundary in Azure for managing traffic isolation.

## Subnet
Logical segment inside a VNet used to host AKS nodes.

## NSG (Network Security Group)
A firewall-like resource with inbound and outbound rules.

## Route Table
A set of routing rules that decides traffic next hop.

## Bring Your Own (BYO)
You create networking components manually and attach them to AKS.

---
# Steps
## Step 1 — Create Resource Group
Example name: `BYO-RG`.

## Step 2 — Create VNet & Subnet
VNet: `192.168.0.0/16`
Subnet: `192.168.0.0/24`

## Step 3 — Create NSG
Name: `my-nsg` (default rules initially).

## Step 4 — Create Route Table
Name: `my-rt` (initially empty).

## Step 5 — Attach NSG & Route Table to Subnet
Subnet → Associate NSG + Route Table.

## Step 6 — Create AKS Cluster Using Custom Subnet
```
az aks create \
  -g BYO-RG \
  -n my-aks-byo \
  --node-count 2 \
  --network-plugin azure \
  --vnet-subnet-id <subnet-ID>
```

---
# Validation
## VNet/Subnet
- Azure CNI => many connected pod IPs.

## NSG
- Contains default rules + AKS injected rules.

## Route Table
- Initially no custom rules.
- AKS injects pod routing entries.

---
# Examples
## Route Table Example — Blocking kubernetes.io
1. nslookup + nc works initially.
2. Add route for `kubernetes.io-IP/32` with next hop "None".
3. nc times out → route works.

## NSG Example — Blocking HTTPS to example.com
1. nslookup + nc works initially.
2. Add outbound deny rule for HTTPS.
3. nc 443 fails but nc 80 works.

---
# Real World Use Cases
## Route Table
- Force tunneling
- Azure Firewall
- On-prem routing

## NSG
- Zero trust policies
- IP-based restrictions
- Port-level restrictions

---
# ASCII Diagram
```
+----------------------------+
|           VNet             |
|  192.168.0.0/16            |
|   +---------------------+  |
|   | Subnet 192.168.0.0/24| |
|   |  AKS Nodes          | |
|   |  +---------------+  | |
|   |  | Pods (CNI)    |  | |
|   |  +---------------+  | |
|   +---------------------+  |
|  NSG + Route Table         |
+----------------------------+
```

