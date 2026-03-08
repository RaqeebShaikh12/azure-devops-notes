
# AKS Kubenet Networking — Detailed Notes

## Important Note: Kubenet Retirement in 2028 (Layman Explanation)
Kubenet is an older AKS networking plugin. Microsoft announced that **Kubenet will be retired on March 31, 2028**, meaning it will no longer be supported.

This means:
- Existing clusters using Kubenet must migrate before 2028.
- New clusters created from Azure Portal no longer offer Kubenet.
- You *can* still create Kubenet clusters via CLI for testing:
```
az aks create --network-plugin kubenet [...]
```

Why this matters:
- Many production clusters still use Kubenet.
- You may be required to support or migrate them.
- Kubenet is useful for learning fundamentals of AKS networking.

---

# 1. What Is a Kubernetes Network Plugin? (Layman Explanation)
A **network plugin** is a software layer inside Kubernetes that makes pod communication possible.

Pods need IPs, and nodes need to route packets. The network plugin handles:
- Assigning pod IP addresses
- Allowing pods to communicate across nodes
- Enabling pods to reach the VNet, internet, and on‑premises networks

Kubenet is the **basic** (legacy) Kubernetes network plugin.

---

# 2. How Kubenet Assigns IPs (Terminology Explained)
### Node IPs
Nodes receive IPs from the **subnet** of the VNet.
These IPs are fully routable inside Azure.

### Pod IPs
Pods **do NOT** receive subnet IPs.
Instead, they receive IPs from a **logical range** called the **Pod CIDR** (Cluster CIDR).

Example ranges:
- VNet: `10.224.0.0/12`
- Subnet: `10.224.0.0/16`
- Pod CIDR: `10.244.0.0/16`

Pods **must not overlap** with:
- Subnet ranges
- Peer VNets
- On‑prem ranges

Otherwise routing conflicts occur.

---

# 3. How Pod CIDR Is Assigned to Nodes
Pod CIDR is broken into **smaller blocks**, and each node receives one block.

Example:
```
Node0 → 10.244.0.0/24
Node1 → 10.244.1.0/24
Node2 → 10.244.2.0/24
```

So:
- Pods on Node0 receive IPs like `10.244.0.x`
- Pods on Node1 receive IPs like `10.244.1.x`

---

# 4. Pod‑to‑Pod Communication on the Same Node
If Pod A communicates with Pod B *on the same node*:
- The node uses its **local routing table**
- The IP is recognized as "local pod network"
- The node uses **ARP** (Address Resolution Protocol) to find the pod’s MAC address
- Packet is delivered directly through the node’s internal network interface

You observed this in the cluster:
- `ip route show` displayed the Pod CIDR for that node
- `arp -a` showed pod IPs mapped to pod MAC addresses

---

# 5. Pod‑to‑Pod Communication Across Nodes
When Pod A on Node0 talks to Pod C on Node1:
- Node0 sends traffic to Azure Route Table
- Azure Route Table tells Node0 the correct **next hop** (Node1)
- Node1 receives the packet, then uses ARP + routing to deliver it to Pod C

Kubenet **requires a route table attached to the subnet**.
AKS automatically manages this.

---

# 6. Pod‑to‑VNet or Pod‑to‑Internet Communication
Pods **do not** have subnet IPs.
So Kubernetes performs **NAT (Network Address Translation)**:
- Pod IP → Node IP

This means external systems see:
- Node IP as the source, never the Pod IP

This is why Kubenet is lightweight — it preserves subnet IP space.

---

# 7. Why Choose Kubenet? (Advantages)
- Saves IP space (pods use Pod CIDR, not subnet)
- Simpler for clusters where:
  - Most communication stays inside the cluster
  - IP conservation is important
- Historically the default networking option

---

# 8. Disadvantages of Kubenet
- Additional hops introduce small latency
- Route table required; maximum **400 routes → max 400 nodes**
- Cannot run **Windows nodes**
- Cannot support **Azure network policies**
- Cannot support **virtual nodes (ACI)**
- Cannot support advanced networking features
- Being retired in 2028

---

# 9. What You Observed in the Demo
You inspected:
- Pod IPs per node
- Routing tables using `ip route`
- ARP cache using `arp -a`
- Azure route table entries

You saw:
- Each node had a `/24` Pod CIDR
- Routes mapped Pod CIDRs to node IPs
- DaemonSet pods shared node IPs (privileged pods)

---

# 10. Summary
Kubenet is:
- Lightweight
- Based on Pod CIDR and NAT
- Simple for small clusters
- Limited in features
- Being retired in 2028

Modern recommendation: **use Azure CNI Overlay**.
