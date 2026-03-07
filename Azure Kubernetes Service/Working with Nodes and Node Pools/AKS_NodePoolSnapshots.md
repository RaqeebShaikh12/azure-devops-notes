
# AKS Node Pool Snapshots — Detailed Notes

## 1. What Are Node Pool Snapshots? (Layman Explanation)
A **node pool snapshot** is like taking a *blueprint* of one of your existing AKS node pools. This blueprint contains:
- The node’s Kubernetes version
- The node image version
- The operating system (Linux/Windows)
- The OS SKU (Ubuntu, Azure Linux, Windows2019, etc.)

Snapshots help you recreate the same environment later, without having to configure everything manually.

---

## 2. What a Snapshot Contains (Terminology Explained)
### **Node Image Version:**
The underlying OS and container runtime image used by the nodes.

### **Kubernetes Version:**
The exact version that node pool used.

### **OS Type:**
Linux or Windows.

### **OS SKU:**
Example: Ubuntu, Azure Linux (Mariner), Windows Server 2019.

### **Azure Resource:**
The snapshot is stored like any Azure object — similar to a disk snapshot.

It does **not** include workloads, pods, or persistent data — only configuration.

---

## 3. What You Can Do With a Snapshot
Snapshots allow you to:
- Create **new node pools** with the exact same configuration
- Create a **new AKS cluster** using the same blueprint
- Upgrade the snapshot to a newer node image or Kubernetes version

Useful for:
- Reproducing environments across Dev → QA → Prod
- Creating identical clusters in multiple regions
- Ensuring consistent base images everywhere

---

## 4. Important Limitations
### **1. VM Family Must Match**
You must use the same VM family as the source node pool.
Example:
- If snapshot came from a *D-series*, new node pool must also be *D-series*.
- If snapshot is from an *N-series* GPU pool, you must use GPU VMs.

Reason: Images and drivers differ between VM families.

### **2. Region Must Match**
Snapshots can only be used **in the same Azure region** where they were created.
Node images are stored regionally.

### **3. Only Configuration, Not Data**
Snapshots don’t contain:
- Pods
- Disks
- App data
- PVCs

They only contain the *settings* of the node pool.

---

## 5. Hands-On Demo Steps

### **Step 1 — Get Node Pool ID**
```
az aks nodepool show   --resource-group <rg>   --cluster-name <cluster>   --name <nodepool>   --query id -o tsv
```
You retrieved the ID of the Mariner node pool.

---

### **Step 2 — Create the Snapshot**
```
az aks nodepool snapshot create   --resource-group <rg>   --name <snapshotname>   --nodepool-id <nodepoolID>   --location <region>
```
Snapshot created successfully.

To fetch the snapshot ID:
```
az aks nodepool snapshot show -g <rg> -n <snapshotname> --query id -o tsv
```
This output shows the Kubernetes version + image version.

---

### **Step 3 — Create a Node Pool From Snapshot**
```
az aks nodepool add   --resource-group <rg>   --cluster-name <cluster>   --name marinerpool2   --snapshot-id <snapshotID>   --node-count 2   --node-vm-size Standard_DS3_v2
```
Node pool created with a *different size* but **same VM family**.

You verified in the portal:
- New node pool appears
- Node Image Version matches snapshot (0.126)

---

### **Step 4 — Cleanup**
```
az aks nodepool delete --cluster <cluster> --name marinerpool2
```
Node pool removed.

---

## 6. Summary
Node pool snapshots allow you to:
- Reproduce identical node pools quickly
- Maintain consistent images across environments
- Simplify multi-cluster rollouts
- Use prebuilt configurations instead of recreating from scratch

They require:
- Same VM family
- Same region
- Supported Kubernetes version + image version

And are extremely useful for:
- Environment replication
- Disaster recovery
- CI/CD cluster creation patterns
