# AKS Networking, Node Pools & Core Components — Notes

## 1. Address Spaces in AKS (Where All the IPs Come From)
AKS uses multiple IP ranges for different purposes. This is why Pods, Nodes, and Services all have different IP formats.

### 1.1 Virtual Network (VNet) & Subnet
- Every AKS cluster runs inside an Azure VNet.
- Nodes (VMs) are placed inside a subnet.
- Node IPs come **from this subnet**.

**Example:**
- Node 1 → 10.224.0.4
- Node 2 → 10.224.0.5

```
Azure VNet
 └── Subnet (AKS Subnet)
       ├── Node VM 1 → 10.224.0.4
       └── Node VM 2 → 10.224.0.5
```

### 1.2 Pod CIDR
- IP range from which **Pods** get their IPs.
- Must NOT overlap with other networks.
- Cannot be changed after cluster creation.

**Example Pod IPs:**
- 10.244.1.17
- 10.244.1.14
- 10.244.1.13

### 1.3 Service CIDR
- Used for ClusterIP services.
- Includes DNS service IP.
- Cannot overlap with Pod CIDR or VNet.

---

## 2. Node Pools in AKS
A node pool is a group of VMs with identical configuration.

### Why Multiple Node Pools?
- Different VM sizes for different workloads.
- Workload isolation.
- Separate scaling & upgrades.

### Types of Node Pools
| Type | Purpose |
|------|---------|
| **System** | Runs system pods (CoreDNS, kube-proxy, metrics server, autoscaler) |
| **User** | Runs application pods |

```
AKS Cluster
 ├── System Node Pool
 └── User Node Pool
```

---

## 3. Accessing AKS Nodes (Without Public IP)
AKS nodes have **no public IPs**. Access options:

### 3.1 kubectl debug (Microsoft Recommended)
Creates a privileged helper pod:
```
kubectl debug node/<node-name> -it
```

### 3.2 kubectl node-shell (Third‑party)
```
kubectl node-shell <node-name>
```

---

## 4. AKS System Components on Worker Nodes
Installed automatically and managed by AKS.

### Linux Services
- **kubelet** → Node agent
- **containerd** → Container runtime

---

## 5. kubelet
- Ensures pods are running.
- Talks with control plane & containerd.

### View kubelet logs
```
journalctl -u kubelet
systemctl status kubelet
```

### View kubelet configuration
```
kubectl proxy
curl localhost:8001/api/v1/nodes/<node>/proxy/configz
```

---

## 6. containerd
- Replaced Docker as runtime.
- More efficient, OCI-compliant.

### containerd commands
```
ctr images list
ctr containers list
ctr tasks logs <id>
```

---

## 7. Azure IP Masquerade Agent
- Runs as a daemonset.
- NATs pod traffic for outbound internet.

### Example NAT flow
```
Pod (10.244.1.17) → Node (10.224.0.4) → Internet
```

---

## 8. Cloud Node Manager
Handles Azure-specific tasks:
- Adds Azure labels & annotations.
- Manages provider IDs.
- Syncs metadata with Azure.
- Reports node health.

```
Cloud Provider Integration Layer
 ├── Node Metadata
 ├── Node Health
 ├── Labels & Annotations
 └── Provider IDs
```
