# Azure AKS — Bring Your Own VNet, Subnet, NSG, and Route Table (BYO Networking)

This document contains **only** the BYO networking concept with full detailed notes, terminology explanations, diagrams, and examples.

---
# 1. Concept Overview
When creating an AKS cluster, Azure can automatically provision networking components such as:
- Virtual Network (VNet)
- Subnet
- Network Security Group (NSG)
- Route Table

However, you can **Bring Your Own (BYO)** networking resources to gain more customization and control. AKS will still inject required rules to maintain cluster functionality, but you can customize them as long as you don't break required settings.

---
# 2. Terminology Explained
## Virtual Network (VNet)
A secure, isolated network inside Azure where resources communicate privately.

## Subnet
A logical segment inside a VNet used to host AKS nodes.

## Network Security Group (NSG)
A firewall-like component controlling inbound and outbound traffic with rules.

## Route Table
Defines how network traffic flows by specifying destination prefixes and next-hop types.

## Bring Your Own (BYO)
You manually create networking components and attach them to AKS instead of letting Azure create and lock them.

---
# 3. Step-by-Step Process
## Step 1 — Create Resource Group
Example: `BYO-RG`.

## Step 2 — Create VNet & Subnet
Example:
- VNet: `my-vnet` using `192.168.0.0/16`
- Subnet: `my-subnet` using `192.168.0.0/24`

## Step 3 — Create NSG
Name: `my-nsg`. Starts with default Azure rules.

## Step 4 — Create Route Table
Name: `my-rt`. No routes initially.

## Step 5 — Attach NSG & Route Table to Subnet
Associating both allows custom policies.

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
# 4. Validation
## VNet/Subnet Behavior
Using Azure CNI, many pod IPs appear under connected devices.

## NSG Behavior
Contains default rules + AKS-required rules.

## Route Table Behavior
Starts empty; AKS adds routing entries for pod communication.

---
# 5. Practical Examples
## Example 1 — Using Route Table to Block Traffic
1. Perform lookup:
   - `nslookup kubernetes.io`
   - `nc kubernetes.io 443`
2. Add route:
   - Destination: `<IP>/32`
   - Next hop: None (drop)
3. Traffic is dropped after propagation.

## Example 2 — Using NSG to Block HTTPS
1. Check connectivity:
   - `nslookup example.com`
   - `nc example.com 443`
2. Add NSG outbound deny rule for port 443.
3. HTTPS fails; HTTP still works.

---
# 6. Real-World Use Cases
## Route Table
- Forcing egress through firewalls
- Routing to on-prem networks
- Blocking unwanted traffic

## NSG
- Zero-trust security
- IP/port-based restrictions
- Enforcing compliance

---
# 7. Diagram
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

---
# End of BYO Networking Notes
