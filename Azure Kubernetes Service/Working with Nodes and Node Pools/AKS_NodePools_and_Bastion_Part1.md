# AKS Node Pools, VM Types, System vs User Node Pools — Detailed Notes (Part 1)

## 1. Virtual Machine Types in Node Pools
You can have two types of virtual machines backing your AKS node pools:
- **Virtual Machine Scale Sets (VMSS)**
- **Virtual Machine Availability Sets (VMAS)**

### Availability Set Overview
An Availability Set is a grouping of **independent VMs** spread across:
- **Fault Domains** (power + network isolation)
- **Update Domains** (groups patched together during maintenance)

Limits:
- Max **20 update domains**
- Max **3 fault domains**

### VM Scale Set Overview
A VMSS is a group of **identical** VMs supporting:
- Autoscaling
- Centralized model definition
- Faster management

VMSS is the **default for AKS**.

### Limitations
**VMAS limitations:**
- Cannot use multiple node pools
- Cannot enable Cluster Autoscaler

**VMSS limitation:**
- Deployed in a single fault domain

---

## 2. Creating an AKS Cluster with Availability Set
You created an AKS cluster using:
```
--vm-set-type AvailabilitySet
```
Portal observations:
- VM disks and NICs appear as *separate* resources
- Availability Set shows VMs distributed across FD/UD

Comparing VMSS:
- VMSS nodes always show **Fault Domain = 1**
- Update domains vary

You confirmed via:
```
az vm list-instances --query "[].[instanceId,platformFaultDomain,platformUpdateDomain]"
```

### Node Pool behavior
VMAS cluster:
- No option to **add node pools**
- No option for **autoscaler** (manual scaling only)

You then deleted this cluster, since the course focuses on VMSS.

---

## 3. System Node Pools vs User Node Pools
AKS has two node pool types:
- **System Node Pool** → runs critical components
- **User Node Pool** → runs application workloads

### 3.1 System Node Pool
Runs critical pods such as:
- CoreDNS
- Metrics Server
- Tunnel/Connectivity agent

It automatically receives label:
```
kubernetes.azure.com/mode = system
```
System pods have **preferred node affinity** toward this label.

Example from your `coredns` pod:
```
nodeAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
    - preference:
        matchExpressions:
        - key: kubernetes.azure.com/mode
          operator: In
          values: [system]
```

### 3.2 User Node Pool
Runs **application pods**. To prevent apps running on system nodes, AKS recommends tainting system pools:
```
kubernetes.azure.com/scalesetpriority=critical-addons-only:NoSchedule
```
System pods have tolerations; app pods normally do not.

You compared this using a restaurant analogy.

### 3.3 Converting Node Pool Types
Rules:
- Cluster must always have **at least 1 system node pool**
- You **can convert user → system**
- You **cannot convert system → user** unless another system pool exists

Portal flow:
```
AKS → Node Pools → Select Pool → Change Type
```

---

## 4. Node Pool OS & Feature Matrix
| Property | System Node Pool | User Node Pool |
|---------|------------------|----------------|
| OS Type | Linux only | Linux or Windows |
| Min Nodes | 1 | 0 |
| Stoppable individually | ❌ No | ✅ Yes |
| Spot supported | ❌ No | ✅ Yes |
| MaxPods range | 30–250 | 10–250 |

Microsoft recommends **separating system + user pools**.

---

## 5. How kubectl debug / node-shell Access Nodes
You revisited connections using:
- `kubectl debug node/<node>`
- `kubectl node-shell` (nsenter)

### 5.1 Inspecting Debug Pod YAML
You extracted YAML to observe key fields:
- `hostIPC: true`
- `hostPID: true`
- `hostNetwork: true`
- Mounting `/` from host
- `nodeName:` targeting specific node

These settings:
- Allow pod to enter host namespaces
- Allow process-level inspection
- Provide full filesystem access

### 5.2 nsenter Pod Enhancements
The nsenter-based pod additionally used:
- `privileged: true`
- Entrypoint using `nsenter` into PID 1

### 5.3 kubectl explain Trick
Example:
```
kubectl explain pod.spec.hostNetwork
```
This provides field-level documentation.

---
