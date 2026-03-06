# AKS DNS, CoreDNS, Autoscaler & CSI – Detailed Notes (Part 1)

## 1. CoreDNS – Authoritative DNS Component in AKS
CoreDNS is the DNS server used inside Kubernetes clusters, including AKS. It acts as the cluster’s internal “phonebook,” translating service or pod names into IP addresses.

### 1.1 What CoreDNS Does
CoreDNS performs:
- Internal service name resolution
- Pod name resolution (if enabled)
- Forwards external DNS queries via the node’s `/etc/resolv.conf`
- Uses a modular plugin architecture to extend capabilities

### 1.2 CoreDNS Plugins Explained (in Layman Terms)
- **Kubernetes Plugin** – Answers DNS queries for services/pods inside the cluster.
- **Forward Plugin** – Sends DNS queries for external domains (e.g., google.com) to Azure DNS.
- **Log Plugin** – Logs DNS queries (disabled by default for performance).

### 1.3 How DNS Lookup Works
When a pod runs `nslookup microsoft.com`:
```
Pod → CoreDNS → Node's /etc/resolv.conf → Azure DNS → Internet
```

### 1.4 Configuring CoreDNS Safely
AKS provides two ConfigMaps:
- `coredns` → DO NOT modify (managed by AKS reconciler)
- `coredns-custom` → Safe for customizations (logging, rewrites, etc.)

### 1.5 Your Demo Summary
- Tailed CoreDNS logs
- Queried internal & external domains
- Enabled the log plugin via `coredns-custom`
- Restarted CoreDNS pods
- Verified logging behavior

---

## 2. DNS Autoscaler in AKS
DNS Autoscaler adjusts CoreDNS replicas based on cluster size.

### 2.1 How Autoscaler Works
Based on node count:
- 1–8 nodes → 2 replicas
- 8–16 nodes → 3 replicas
- 16–32 nodes → 4 replicas

### 2.2 Demo You Performed
- Checked CoreDNS replicas (2)
- Modified autoscaler config to force 3
- Confirmed a new pod was created
- Reverted to original settings

---

## 3. CSI (Container Storage Interface)
CSI is the modern, standardized storage mechanism for Kubernetes.

### 3.1 Why CSI Exists (Layman Terms)
Before CSI, Kubernetes had storage drivers “built-in,” which slowed updates. CSI allows cloud providers like Azure to ship storage features independently.

### 3.2 CSI Drivers in AKS
Runs as DaemonSets:
- Azure Disk CSI
- Azure File CSI
- Azure Blob CSI

### 3.3 What CSI Node Components Do
- Attach/detach volumes
- Mount/unmount storage
- Ensure persistent volumes work across nodes

---
