# Azure CNI Overlay — Detailed Concept Notes

## 1. Why Azure CNI Overlay Exists
Traditional Azure CNI assigns an IP from the VNet to every pod. This requires IP planning and can cause IP exhaustion as the cluster scales.

Azure CNI Overlay avoids this by giving pods IPs from a logical, separate pod CIDR—not from the VNet.

---
## 2. How Azure CNI Overlay Works
### 2.1 Pod IPs
Pods get IPs from a separate internal pod CIDR managed by Azure.

### 2.2 Overlay Network
Azure creates an internal overlay network for pod-to-pod communication. No UDRs, IP forwarding, or encapsulation is required.

### 2.3 Traffic Flow
- Pod → Pod: Uses overlay network directly.
- Pod → External: NAT happens at node level. Source seen as node IP.

---
## 3. /24 Allocation Per Node
Azure assigns each node a /24 block from the pod CIDR for predictable scaling.

---
## 4. Creating an AKS Cluster with Azure CNI Overlay
Command:

```
az aks create \
  -g <resource-group> \
  -n <cluster-name> \
  --network-plugin azure \
  --network-plugin-mode overlay \
  --node-count 2
```

---
## 5. Validation Observations
### Portal Behavior
- Traditional CNI: Many pod IPs appear in the VNet.
- Overlay: Only nodes appear.

### On-node Behavior
ARP table shows overlay pod IPs.

---
## 6. Advantages
- Efficient VNet IP Usage
- Great for internal-heavy traffic
- No UDRs
- 1000–5000 node support
- Better performance than Kubenet

---
## 7. Disadvantages
- NAT hop for external traffic
- No support for Virtual Nodes or AGIC
- Supports Windows Server 2022 only (not 2019)

---
## 8. Comparison Table
| Feature | Kubenet | Azure CNI | Azure CNI Overlay |
|--------|---------|-----------|-------------------|
| Pod IP source | Pod CIDR | VNet | Pod CIDR |
| Uses VNet IPs | No | Yes | No |
| Best for | Internal | External | Internal, large clusters |
| Max nodes | 400 | 1000–5000 | 1000–5000 |
| UDR required | Yes | No | No |
| Windows support | No | Full | Win 2022 only |
| AGIC support | Yes | Yes | No |

---
## 9. Other Network Plugin Options
- Azure CNI variations
- Azure CNI Powered by Cilium
- Bring Your Own CNI

Reference: https://learn.microsoft.com/en-us/azure/aks/concepts-network-cni-overview

---
## 10. Optional Diagram
### Pod IP Structure
```
+----------------------------+
| Azure VNet                |
|  +----------------------+  |
|  | Node                |  |
|  |  +----------------+  |  |
|  |  | Pod /24 range |  |  |
|  |  +----------------+  |  |
|  +----------------------+  |
+----------------------------+
```
