# Azure AKS — Bring Your Own VNet, Subnet, NSG, and Route Table (FULL DETAILED NOTES)

This file contains **fully detailed, expanded, non‑summarized notes**, rewritten with maximum depth to match the lecture exactly.

---
# 1. Introduction
When creating an AKS (Azure Kubernetes Service) cluster, Azure normally provisions networking components on your behalf:
- Virtual Network (VNet)
- Subnet
- Network Security Group (NSG)
- Route Table

If you do **not** create these resources yourself, AKS will **automatically create and manage** them with default configurations.

However, Azure also allows a **Bring Your Own (BYO)** model where *you* manually create these networking components first and then attach them to AKS during cluster creation. This gives more control and flexibility, especially in enterprise environments where networking rules are strict.

Even in the BYO model, AKS **still requires partial control**. For example:
- AKS will automatically add/remove routes in your route table so that pods running on different nodes can communicate.
- AKS will enforce certain NSG rules to ensure cluster traffic works as required.

You can customize these components **as long as you do not break AKS networking requirements**.

---
# 2. Terminology (Full Explanation)

## 2.1 Virtual Network (VNet)
A VNet is an isolated, customizable network inside Azure. It functions similarly to a traditional on‑premises network but in the cloud. Resources inside a VNet can communicate with one another privately.

A VNet defines the address space (for example, `192.168.0.0/16`).

## 2.2 Subnet
A subnet is a smaller segment inside the VNet address space.

For example:
- VNet: `192.168.0.0/16`
- Subnet: `192.168.0.0/24`

AKS nodes will be deployed **inside a subnet**.

If using Azure CNI, pod IPs will also come from this subnet.

## 2.3 Network Security Group (NSG)
An NSG is similar to a cloud firewall. It contains inbound/outbound rules that either allow or block traffic.

Each rule defines:
- Priority
- Source / Destination
- Port
- Protocol
- Action (Allow / Deny)

NSGs can be applied at:
- NIC level
- Subnet level

When using a **custom NSG**, AKS allows you to modify it as long as cluster-required traffic remains allowed.

## 2.4 Route Table
A Route Table contains routing rules telling Azure where packets should go.

A route contains:
- Destination prefix (example: IP/32)
- Next-hop type (Internet, Virtual Appliance, None, VNet, etc.)

If next-hop = **None**, packets are effectively dropped.

## 2.5 Bring Your Own (BYO)
This means YOU create the networking components manually instead of AKS auto-creating them.

Azure allows this for:
- VNet
- Subnet
- Route table
- NSG

This is useful for custom security, compliance, and routing needs.

---
# 3. Creating BYO Networking Resources (FULL WALKTHROUGH)

## Step 1 — Create Resource Group
Example name: `BYO-RG` (BYO = Bring Your Own).

## Step 2 — Create Virtual Network and Subnet
Create a VNet named `my-vnet` with address space:
```
192.168.0.0/16
```

Create a subnet named `my-subnet`:
```
192.168.0.0/24
```

This subnet will host the AKS nodes.

## Step 3 — Create NSG
Create an NSG named:
```
my-nsg
```
This NSG initially contains default Azure rules.

## Step 4 — Create Route Table
Name it:
```
my-rt
```
Initially: No routes.

## Step 5 — Assign NSG & Route Table to Subnet
Attach both to `my-subnet`:
- Subnet → NSG: `my-nsg`
- Subnet → Route Table: `my-rt`

Now your subnet is fully custom.

---
# 4. Create AKS Cluster Using Custom Networking
Use the command:
```
az aks create \
  -g BYO-RG \
  -n my-aks-byo \
  --node-count 2 \
  --network-plugin azure \
  --vnet-subnet-id <subnet-resource-id>
```

Here you pass your subnet ID manually.

AKS will now attach its nodes to your custom subnet instead of creating its own.

---
# 5. Behavior After Cluster Creation

## 5.1 VNet Connected Devices
If using Azure CNI:
- Many connected IPs appear under the subnet
- These represent **pods and node NICs**

## 5.2 NSG Behavior
The NSG still contains:
- Azure default rules
- Your custom rules
- AKS-required rules

## 5.3 Route Table Behavior
Initially empty.

After cluster creation, AKS **automatically injects pod routing entries** for node-to-node communication.

You are free to add more routes—just don’t break the cluster.

---
# 6. Real Examples (FULL DETAILS)

## Example 1 — Customize Route Table to DROP Traffic
Goal: Block access to `kubernetes.io`.

### Step A — Test initial connectivity
```
nslookup kubernetes.io
nc kubernetes.io 443
```
Both work.

### Step B — Add a route to drop traffic
- Destination: `<IP-of-kubernetes.io>/32`
- Next hop: `None`

This means: **drop all packets** to that IP.

### Step C — After propagation (~30–60 sec)
Run:
```
nc kubernetes.io 443
```
Result: TIMEOUT — route is working.

---
## Example 2 — Use NSG to Block HTTPS to example.com
### Step A — Test initial connectivity
```
nslookup example.com
nc example.com 443
```
Both work.

### Step B — Add NSG outbound deny rule
- Destination: `<IP-of-example.com>`
- Destination port: 443 (HTTPS)
- Action: Deny

### Step C — After propagation
```
nc example.com 443
```
Result: BLOCKED.

But HTTP port 80 still works:
```
nc example.com 80
```
This shows NSG rule is correctly filtering traffic.

---
# 7. Real-World Use Cases (Deep Explanation)

## Route Tables
Enterprises often use route tables to:
- Force all egress through a firewall (Azure Firewall, Palo Alto, Fortinet, etc.)
- Block certain destinations
- Route traffic to on‑prem through VPN/ExpressRoute
- Implement DMZ patterns

## NSGs
Common uses:
- Zero-trust rules
- Allow only specific outbound destinations
- Restrict access between workloads
- Enforce security compliance (PCI, HIPAA, etc.)
 
---
# 8. Detailed Architecture Diagram (ASCII)
```
+-------------------------------------------------+
|                     Azure VNet                  |
|                 192.168.0.0/16                  |
|                                                 |
|   +-------------------------------------------+ |
|   |                Subnet                     | |
|   |             192.168.0.0/24                 | |
|   |                                            | |
|   |  +-------------+      +-------------+      | |
|   |  |   AKS Node  |      |   AKS Node  |      | |
|   |  |  (VM Scale  |      |  (VM Scale  |      | |
|   |  |    Set)     |      |    Set)     |      | |
|   |  +-------------+      +-------------+      | |
|   |        |                     |             | |
|   |     Pods                  Pods             | |
|   |   (Azure CNI)         (Azure CNI)          | |
|   +-------------------------------------------+ |
|                                                 |
|  NSG Applied: my-nsg                            |
|  Route Table Applied: my-rt                     |
+-------------------------------------------------+
```

---
# End of Fully Detailed BYO Networking Notes
