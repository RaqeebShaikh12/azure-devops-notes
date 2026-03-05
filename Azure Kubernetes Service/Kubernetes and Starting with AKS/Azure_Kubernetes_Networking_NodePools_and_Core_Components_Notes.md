
# AKS Detailed Notes (Full, Non‑Truncated)

This file contains **full detailed notes** based on your provided lecture text. Nothing is summarized or compressed into short bullets. All explanations are expanded to ensure you can study effectively.

---

## 1. Address Spaces in AKS (Where All IPs Come From)
When you create an AKS cluster, Azure automatically provisions several IP ranges used for different networking purposes. These ranges are **critical** to understand because Pods, Nodes, and Services all receive IP addresses from different CIDRs.

### 1.1 Virtual Network (VNet) and Subnet
Every AKS cluster is deployed into an Azure Virtual Network. This VNet is responsible for providing network connectivity for your nodes.

- Each node (which is essentially a VM) receives an IP from the subnet.
- These IPs are visible when you run `kubectl get nodes -o wide`.
- Example from your output:
  - Node 1 IP → `10.224.0.4`
  - Node 2 IP → `10.224.0.5`

These are **Azure VM private IPs** allocated from the **AKS subnet** belonging to the infrastructure resource group of the AKS cluster.

You can confirm this in Azure Portal: go to the AKS cluster → Properties → Infrastructure Resource Group → Virtual Network → Subnets → Connected Devices.

This confirms that the nodes shown by Kubernetes match the VMs shown in Azure.

```
Azure VNet
 └── AKS Subnet
        ├── Node VM 1 → 10.224.0.4
        └── Node VM 2 → 10.224.0.5
```

---

### 1.2 Pod CIDR (Pod Address Space)
Pods do NOT receive IPs from the VNet or subnet.

Instead, Kubernetes assigns Pod IPs from a **Pod CIDR range**, configured at cluster creation.

Important characteristics:
- Should not overlap with VNet or on‑premises networks.
- Cannot be changed after cluster creation.
- Can be reused by multiple AKS clusters (not shared, just same range).

Example Pod IPs from your cluster:
- `10.244.1.17`
- `10.244.1.14`
- `10.244.1.13`

You verified this using:
```
kubectl get pods -o wide
```
and matched it to Azure portal’s displayed Pod CIDR.

Using subnet calculator (`sipcalc`), you validated that all pod IPs fall inside the Pod CIDR.

---

### 1.3 Service CIDR
A Kubernetes Service also receives an IP address (ClusterIP), but NOT from Pod CIDR or VNet.

Service IPs come from **Service CIDR**, another fixed range assigned at AKS creation.

Important points:
- Used by internal services only.
- Includes special IPs like the Kubernetes DNS service.
- Cannot overlap with Pod CIDR or VNet.
- Cannot be changed later.

Example service IPs you observed:
- Kubernetes default service → something like `10.X.X.1`
- CoreDNS service → IP inside the Service CIDR

You validated this using:
```
kubectl get svc -A
```
and checking that all ClusterIPs fall within the Service CIDR.

---

## 2. Node Pools in AKS
Node pools are the **groups of identically configured nodes** within an AKS cluster.

### Why Node Pools Matter
- They define the compute environment for your applications.
- Allow workload isolation.
- Allow separate scaling and upgrades.
- Allow mixing VM sizes or OS types.

### System vs User Node Pools
AKS supports two pool types:

#### System Node Pool
- Hosts critical system services.
- Runs components like:
  - CoreDNS
  - Metrics server
  - kube-proxy
  - Azure CNI plugins
- Needs to be stable and not overloaded.

#### User Node Pool
- Hosts **application workloads**.
- Should be used to run your deployments, pods, and services.

**Best Practice:** Always keep system pods on the system node pool and apps on user pools.

---

## 3. How to Access AKS Nodes (No Public IPs)
AKS nodes do NOT have public IPs by default.
So to access them, AKS provides two safe debugging tools.

### 3.1 Method 1 — `kubectl debug`
This is the official, recommended method.
It launches a privileged pod on the node and attaches you to its shell.

Example:
```
kubectl debug node/<node-name> -it
```

Inside the debug container, you can:
- Run Linux commands
- Inspect logs
- Troubleshoot issues

### 3.2 Method 2 — `kubectl node-shell` (3rd Party)
This tool uses **nsenter** under the hood and gives deeper access.

Example:
```
kubectl node-shell <node-name>
```

This creates a temporary privileged pod and attaches you directly into the node namespaces.

You confirmed this by checking pods created in kube-system namespace.

---

## 4. Kubernetes Components Installed on Worker Nodes
AKS automatically deploys several Kubernetes components into the nodes.
Some run as Linux services, others as daemonsets, and others as deployments.

### Components installed as Linux services
- **kubelet** – controls all pod lifecycle on a node.
- **containerd** – new container runtime that replaced Docker.

### Components installed as Deployments
- coredns
- metrics-server
- azure policies
- autoscaler helpers

### Components installed as DaemonSets
- azure-ip-masq-agent
- kube-proxy
- cloud-node-manager
- CSI drivers (Azure Disk & Azure File)

These components are managed by AKS.
They automatically recreate themselves if deleted.
They revert if modified.

You demonstrated this by deleting the CoreDNS deployment and watching it auto‑recreate.

---

## 5. Kubelet (Node Agent)
Kubelet is a Linux service running on every AKS node.
Its responsibilities include:
- Communicating with Kubernetes API server.
- Ensuring that containers described in pod specs are running.
- Reporting status of pods and node.
- Handling liveness/readiness probes.

### Checking kubelet configuration
You ran:
```
kubectl proxy
curl localhost:8001/api/v1/nodes/<node>/proxy/configz
```
This returns full kubelet configuration including:
- eviction thresholds
- resource reservations
- kube-reserved values
- container runtime settings
- authentication settings

### Viewing kubelet logs
You accessed the node using kubectl debug or node-shell.
Then ran:
```
journalctl -u kubelet --no-pager
systemctl status kubelet
```
These logs are helpful for troubleshooting node scheduling issues.

---

## 6. containerd (Container Runtime)
containerd is the runtime running on AKS nodes.
Docker is no longer used as a runtime, although you still build images with Docker.

### Why containerd?
- Faster pod startup time
- Lower overhead
- Simpler architecture
- Fully Kubernetes CRI compliant

### Using containerd CLI (ctr)
Example commands:
```
ctr images list
ctr containers list
ctr tasks list
ctr tasks logs <container-id>
```
You used these commands to examine running containers on AKS nodes.

---

## 7. Azure IP Masquerade Agent
Runs as a DaemonSet on each node.
Responsible for creating **iptables NAT rules**.

### Purpose
- Allows pods to communicate to the internet using the **node’s IP** instead of pod IP.
- Hides (masquerades) pod IP addresses when leaving the node.

### Non-masquerade ranges
Some internal IPs (like Pod CIDR itself) are excluded from NAT.
This is visible in its iptables rules.

---

## 8. Cloud Node Manager
Cloud Node Manager manages all cloud‑specific node operations.

### Responsibilities
- Set provider IDs
- Add Azure-specific labels (region, VM size)
- Add annotations required by AKS
- Detect node lifecycle events
- Verify node health
- Sync node metadata

This component is key for integrating Kubernetes with Azure Cloud.

---

