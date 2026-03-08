
# Azure CNI Networking Plugin — Detailed Notes

## 1. What Is Azure CNI? (Layman Explanation)
Azure CNI (Container Networking Interface) is the **advanced network plugin** for AKS. Unlike Kubenet—where nodes get subnet IPs but pods get logical IPs—Azure CNI assigns **real subnet IPs** to:
- Nodes
- Pods

This allows pods to be fully routable inside the Azure VNet, just like virtual machines.

---

## 2. How to Create a Cluster with Azure CNI
You specify the Azure CNI network plugin using:
```
--network-plugin azure
```
Example:
```
az aks create   --resource-group <rg>   --name <cluster>   --network-plugin azure   --node-count 2
```

Azure CNI has two modes:
- **Traditional (default)** – pods get subnet IPs
- **Dynamic allocation / Enhanced subnet** – pods get IPs from a **separate pod subnet**

Dynamic mode requires:
```
--pod-subnet-id <subnetID>
```

---

## 3. How IP Addressing Works in Azure CNI
### Traditional Mode
- Nodes get IPs from subnet
- Pods also get IPs from the **same** subnet
- IPs for pods are **pre‑allocated per node** based on the `maxPods` setting

### `maxPods` Explained (Layman Explanation)
`maxPods` defines the **maximum number of pods a node can host**.
Example:
```
maxPods = 30
```
A node will get IP space reserved for:
- 1 IP for the node
- Up to 30 pod IPs

However, **not all pods consume unique IPs**:
- System pods like kube-proxy or IP‑masq‑agent use the **node’s IP**, not separate IPs.

This explains why the IP math doesn’t always match the `maxPods` number.

---

## 4. Pod‑to‑Pod Communication
### Same node or different node:
Azure CNI enables **direct routing**, no intermediary hops.

### Pod → VNet Device
The VNet device sees **pod IP** as the source.

### Pod → Internet / External Networks
By default:
- Source = **node IP** (due to masquerading)
- This can be changed by customizing NAT rules

---

## 5. Why Subnet IP Ranges Look Off (Your Observation)
You saw node0 assigned:
```
10.224.0.4 – 10.224.0.32
```
This is because:
- Reserved IPs
- Node IP
- System pods using node IP
- Remaining IPs reserved for workloads

It is **not** meant to equal `maxPods + 1`. It is based on the network plugin’s internal allocation model.

---

## 6. Pod Scheduling Capacity Demonstration
You deployed:
```
kubectl create deploy nginx --image nginx --replicas 60
```
Cluster had:
- 2 nodes
- `maxPods = 30`

Total capacity:
- 2 × 30 = **60 pods**

Your observation:
- Some pods were still pending until the cluster stabilized
- System pods occupy a few slots

Per‑node validation (grep):
- 30 pods were scheduled on node0
- 30 pods were scheduled on node1

This matches expected behavior.

---

## 7. Advantages of Azure CNI
### ✔ Direct VNet Integration
Pods get **real VNet IPs** → full connectivity.

### ✔ Lower Latency
No extra NAT hops for pod‑to‑pod traffic.

### ✔ No Route Tables Required
Azure CNI doesn’t rely on user‑defined route tables (unlike Kubenet).

### ✔ Multiple AKS Clusters Can Share the Same Subnet
This is impossible with Kubenet.

### ✔ Supports Advanced Features
- Windows nodes
- Azure Network Policy
- Virtual Nodes (ACI)

---

## 8. Disadvantages of Azure CNI
### ❌ High IP Consumption
Each pod needs a real subnet IP.
Large clusters can quickly exhaust IP space.

### ❌ Requires Careful IP Planning
If a cluster grows unexpectedly → subnet exhaustion.

### ❌ Upgrades Need Buffer Nodes
Upgrades temporarily add an extra node requiring IPs.

Example:
- Node IP
- + Pod IPs based on `maxPods`

### ❌ Higher Complexity
Traditional mode requires large subnets.
Dynamic mode requires separate pod subnet.

---

## 9. Dynamic Allocation of Pod IPs (Enhanced Subnet Mode)
Azure CNI’s dynamic mode solves IP exhaustion issues.

### Improvements:
- Pods get IPs **from a pod subnet**, not node subnet
- Node subnet and pod subnet are independent
- Much more scalable
- Multiple clusters/pools share a single pod subnet
- Efficient IP usage

### Benefits:
- Better flexibility
- Supports very large clusters
- No performance hit — pods still use VNet IPs

---

## 10. Summary
Azure CNI is the advanced networking plugin that:
- Gives nodes and pods VNet IPs
- Enables direct communication
- Supports large clusters and Windows nodes
- Removes Kubenet’s limitations

But requires:
- More IP planning
- Larger subnets (unless using dynamic mode)
- Understanding of pod IP reservations

Dynamic CNI and enhanced subnet mode address most sizing issues.

Azure CNI Overlay is another option we will cover in the next concept.
