# AKS Metrics Server & Azure Infrastructure Components – Detailed Notes (Part 1)

## 1. Metrics Server in AKS (Detailed + Layman-Friendly)
The **Metrics Server** is a Kubernetes component installed as a *Deployment* in the `kube-system` namespace. It plays a critical role by collecting **CPU and memory usage** information from every node and pod.

### 1.1 What Metrics Server Does (Layman Terms)
Think of Metrics Server as a **fitness tracker** for your cluster. It continuously gathers resource usage:
- Node CPU / Memory usage
- Pod CPU / Memory usage

It DOES NOT store historical data. It only provides **live usage metrics**.

### 1.2 Where Metrics Come From
Metrics Server pulls data from **kubelet** running on each node.
```
Kubelet → Metrics Server → Kubernetes API → kubectl top
```

### 1.3 What Uses Metrics Server?
- **Horizontal Pod Autoscaler (HPA)** → scales pods using CPU/Memory
- **Vertical Pod Autoscaler (VPA)** → adjusts container requests/limits
- **kubectl top** → allows humans to check real-time resource usage

### 1.4 Commands You Used
Check metrics-server:
```
kubectl get deploy -n kube-system | grep metrics
```
Query node usage:
```
kubectl top node
```
Query pod usage:
```
kubectl top pod
```

### 1.5 Demonstration You Performed
You simulated failure of metrics-server:
1. Cordon all nodes → no scheduling
2. Delete metrics-server pod
3. New pods stuck in Pending
4. `kubectl top` stopped working → failed
5. Uncordon nodes → metrics-server recreated
6. `kubectl top` started working again

This confirmed metrics-server is **essential for cluster metrics**.

---

## 2. Azure Resource Groups in AKS
When creating an AKS cluster, two resource groups are involved:

### 2.1 AKS Resource Group (User RG)
This is where *you* deploy AKS.

### 2.2 Infrastructure Resource Group (Node RG)
Automatically created by Azure.
Contains all *managed infrastructure*, such as:
- VM Scale Sets
- Load Balancers
- Route Tables
- Network Interfaces
- Managed Identity
- Disks

### 2.3 Important Rules
- You **should not manually modify** infrastructure resources.
- Customizing VMSS or LB manually breaks reconciliation.
- If cluster is deleted → Infra Resource Group is also deleted.

### 2.4 Customizable Resources
Some resources can be pre-created and passed into AKS:
- Virtual Network
- Subnets
- Public IPs

These will **not** be deleted when cluster is deleted.

---

## 3. Virtual Machine Scale Set (VMSS)
VMSS is the Azure compute layer that AKS uses for nodes.

### 3.1 What VMSS Is (Layman Terms)
Think of VMSS as a factory that builds **identical VMs** to serve as AKS nodes.

### 3.2 Role of VMSS in AKS
- Each node pool = one VMSS
- Scaling node pool = scaling VMSS instances
- VMSS instances = actual Kubernetes nodes

### 3.3 Base-36 vs Base-10 Node Names
Node name contains:
- Base-36 representation (computer name)
- Base-10 instance ID

Example:
```
Instance ID: 3
Node Name: aks-nodepool1-000003 (base-10)
Computer name internally: something like 'aksnp1-00000A' (base-36)
```

### 3.4 VMSS Scaling Warning
**Never scale VMSS directly!**
Scaling must be done via AKS:
```
az aks nodepool scale
```
If you scale VMSS manually, AKS will override changes.

---
