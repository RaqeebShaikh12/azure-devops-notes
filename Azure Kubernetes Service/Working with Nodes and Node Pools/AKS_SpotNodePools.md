# AKS Spot Node Pools – Detailed Notes (Chunk 1)

Hello and welcome to this lecture about spot node pools.

Spot nodes are a distinct category of VMs that let you leverage Azure's underutilized capacity at a significant cost reduction of up to 90%.

A node pool with the priority of **Regular** is automatically created when a cluster is created. In addition to that, a **Spot node pool** can be deployed.

Using Spot VMs for your cluster nodes allows you to reduce costs substantially because they take advantage of Azure's unused capacity. However, this depends heavily on:
- Node size
- Region
- Time of day
- Overall available Azure capacity

Spot nodes behave like regular instances, **but at any time**, if Azure needs capacity back, they will **evict the Spot nodes**.

If capacity is available when you request a Spot node pool, Azure will allocate the Spot nodes. There is **no SLA** or **high availability** guarantee.

Spot nodes are ideal for workloads that tolerate:
- Evictions
- Early terminations
- Interruptions

Examples:
- Batch processing jobs
- CI/CD workloads
- Development environments
- Test environments

### Important Notes
- The **default node pool cannot be a Spot node pool**.
- You must always have **at least one Regular node pool**.
- Spot node pools must use **Virtual Machine Scale Sets (VMSS)**.

### Spot Node Automatic Labels & Taints
A Spot node pool automatically gets:

Label:
```
kubernetes.azure.com/scalesetpriority=spot
```

Taint:
```
kubernetes.azure.com/scalesetpriority=spot:NoSchedule
```

This prevents system pods from scheduling on Spot nodes.

For pods that you **want** to run on Spot nodes, you must add:
- Toleration
- Node affinity

---

## Spot Node Pool Parameters
When creating a Spot node pool, key parameters include:

### 1. Priority
```
--priority Spot
```
(Regular is the default)

### 2. Eviction Policy
- **Delete** (default) → evicted nodes are deleted
- **Deallocate** → evicted nodes are stopped but still count toward quotas

### 3. Spot Max Price
The maximum price you are willing to pay (USD/hour). Options:
- `-1` → Never evicted based on price (capacity-only eviction)
- A number up to 5 decimals, like:
```
0.98765
```

Price varies by region and VM size.

---

## Demonstration: Scheduling Pods on Spot Nodes
You created a Deployment with **no affinity/toleration**, causing pods to remain in **Pending** state until a Spot node pool is created.

You described one pending pod:
```
0/3 nodes available: node(s) didn't match Pod's node affinity selector.
```

This is expected: pods requested Spot nodes, but no Spot pool existed.

---

## Creating a Spot Node Pool
You attempted to create a node pool with:
```
az aks nodepool add --priority Spot --eviction-policy Delete --spot-max-price -1
```

Azure returned:
```
There is not enough Spot VM capacity in this region.
```

This error means Azure's current capacity could not satisfy your request.
This demonstrates that **Spot capacity is not guaranteed**.

You attempted multiple times over several days, still no available capacity.

This reinforces that Spot node pools:
- Are opportunistic
- Should not be used for production
- Are dependent on Azure’s unused capacity at that exact time

---

## Final Notes
Spot node pools are extremely cost‑effective but come with limitations:
- No guaranteed capacity
- Nodes can disappear at any moment
- Only suitable for tolerant workloads
- Require regular node pools

Thank you for watching and I will see you in the next lecture.
