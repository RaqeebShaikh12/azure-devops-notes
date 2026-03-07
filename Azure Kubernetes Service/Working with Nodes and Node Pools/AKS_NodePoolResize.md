
# AKS Node Pool Resize Workaround — Detailed Notes

## 1. Why You Cannot Resize Nodes Directly (Layman Explanation)
In AKS, node pools run on Virtual Machine Scale Sets (VMSS). Even though VMSS normally allows resizing VMs, **AKS manages these VMs automatically using its own control plane**.

This means:
- You **cannot** resize AKS node VMs manually.
- If you do resize them manually, **AKS will revert the change** during the next *PUT operation* such as:
  - Upgrade
  - Scale
  - Reconcile
  - Stop/Start cluster

AKS always ensures nodes match the configuration stored in its API.

So resizing VMs at Azure VMSS level is **unsupported**.

---

## 2. Why Resizing Is Needed
You may want to resize nodes because:
- Deployments have increased.
- Workloads require more CPU or RAM.
- Nodes are underutilized and you want to reduce cost.

But because direct resizing is not allowed, AKS provides a **safe workaround**.

---

## 3. Supported & Safe Way to Resize a Node Pool
### ✔ You CANNOT: resize existing nodes.
### ✔ You CAN: create a new node pool with the desired size.

This is the official AKS‑recommended way.

### **Workaround Steps (Terminology Explained)**
Below are the concepts used:

### **Cordon**
Marks a node as **unschedulable**. New pods will NOT land on that node.

```
kubectl cordon <node>
```

### **Drain**
Gracefully evicts pods from the node so they move to other nodes.

```
kubectl drain <node> --ignore-daemonsets --delete-emptydir-data
```

### **Node Pool Replacement Workflow**
1. **Create a new node pool** (np2) with the VM size you want.
2. **Cordon old nodes** in np1 → prevents new scheduling.
3. **Drain old nodes** → moves existing pods to np2.
4. **Delete old node pool** (np1).

This effectively “resizes” your node pool.

---

## 4. Additional Requirement: System Node Pools
AKS requires **at least one system node pool**.

So during resizing:
- If np1 is a **system** node pool → np2 must also be created as **system**.
- After migration, np1 can be deleted safely.

If you need to keep the same node pool name:
### Extra steps:
1. Delete old np1.
2. Rename np2 to np1 (by recreating).
3. Drain np2.
4. Delete np2.

---

## 5. Node Pool Snapshot Usage
You can use a **node pool snapshot** (discussed in previous lecture) to create a new node pool **if the new VM size belongs to the same VM family**.

Snapshots ensure consistent:
- Kubernetes version
- Node image version
- OS image

---

## 6. Hands-On Demonstration
You replaced the Mariner node pool with a new pool using Standard B2ms.

> Note: Burstable B‑series is NOT recommended for system pools, but acceptable for testing.

### **Step 1 — Create New Node Pool**
```
az aks nodepool add   --cluster-name <cluster>   --resource-group <rg>   --name mariner2   --node-count 1   --node-vm-size Standard_B2ms   --os-sku AzureLinux
```
You confirmed node pool creation:
```
kubectl get nodes
```

---

## Step 2 — Cordon Old Node Pool
Before draining, you cordoned np1:
```
kubectl cordon <node-name>
```
The node status showed:
```
SchedulingDisabled
```

Why cordon first?
- If you have **multiple old nodes**, draining without cordon can cause pods to jump between old nodes again.

---

## Step 3 — Drain Old Node
```
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data
```
You observed pods being evicted and recreated on new nodes.

You verified:
```
kubectl get nodes
kubectl get pods -o wide
```
Pods were running on the new Standard B2ms node.

---

## Step 4 — Delete Old Node Pool
You deleted the original Mariner node pool from the Azure portal.

This fully completed the resize procedure.

The new node pool remained as a **user** node pool, which is acceptable because:
- You already had an existing system pool.

---

## 7. Summary
Resizing node pools directly in AKS is **not supported**. The correct method is:
1. Add new node pool with new VM size.
2. Cordon + drain old nodes.
3. Delete old node pool.

This is safe, repeatable, and fully supported by AKS.
