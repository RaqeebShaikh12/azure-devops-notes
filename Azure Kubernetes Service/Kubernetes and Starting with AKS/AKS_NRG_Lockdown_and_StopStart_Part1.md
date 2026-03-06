# AKS NRG Lockdown, Mistakes, Resource Groups – Detailed Notes (Part 1)

## 1. Introduction to Common Mistakes & NRG Lockdown
This lecture focuses on a common mistake AKS users make—performing **direct, unsupported actions** on resources inside the **Node Resource Group (NRG)**—and how the **NRG Lockdown** feature prevents such issues.

We studied:
- Resource Groups in AKS
- Unsupported node resource group actions
- Common mistakes & consequences
- Correct configuration methods
- NRG Lockdown feature (ReadOnly mode)
- How to fix mistakes using reconciliation operations

---

## 2. Resource Groups in AKS
Before creating an AKS cluster, you place it inside a **Resource Group**.
During AKS creation, Azure automatically creates a **Node Resource Group (NRG)**, sometimes called the **Infrastructure Resource Group**.

This NRG contains resources AKS needs:
- VM Scale Sets
- Load Balancer
- Public IPs
- Route Tables
- Virtual Network (if cluster-created)

Important:
- **NRG is managed by AKS**, not the user.
- **Deleting AKS deletes the NRG automatically**.

---

## 3. Unsupported Direct Actions on Node Resource Group
An unsupported action is any action that:
- Breaks cluster functionality
- Causes future issues
- Puts cluster into an **unsupported state**
- Cannot be repaired even by MS support in severe cases

### 3.1 What “Direct Actions” Means
Direct actions = using Azure infrastructure APIs (IaaS):
- Azure Portal operations
- Azure CLI commands like `az vmss`, `az network lb`, `az vm`, `az identity`
- ARM templates modifying resources directly
- Bicep deployments on NRG
- Terraform targeting the VMSS, LB, PIP etc.

### 3.2 Why They Are Unsupported
These actions modify Azure resources **outside AKS’s desired state**.

During the next PUT operation (upgrade, scale, reconcile, stop/start), AKS will:
- Compare actual state vs desired state
- Detect mismatch
- Overwrite or recreate resources
- Potentially break apps or connectivity

Example:
You modify LB frontend IP directly → AKS reconciles → reverts to old IP → app stops responding.

---

## 4. Demonstration of Breaking the Cluster
You created an AKS cluster and then **deleted the VM Scale Set** directly.

Consequences:
- Nodes went into **NotReady** state
- Cluster unusable
- Production impact: 100% downtime

### 4.1 How You Fixed It
Run:
```
az aks update -g <rg> -n <cluster>
```
This triggers a reconciliation.
AKS compared desired state → detected missing VMSS → recreated VMSS.

Nodes returned to Ready state.

---

## 5. Correct Ways to Perform Common Operations
### 5.1 Create/Delete Node Pools
❌ WRONG: Creating a VMSS manually
❌ WRONG: Deleting VMSS manually

✔ RIGHT: Use AKS node pools page

To add node pool:
- Portal → AKS → Node Pools → Add

To delete node pool:
- Only if another **system** pool exists
- Deleting node pool automatically deletes VMSS

---

### 5.2 Configure Autoscaling
❌ WRONG: Enable autoscale from VMSS page
✔ RIGHT: Enable autoscaler at AKS level

Portal → AKS → Node Pools → Scale

---

### 5.3 Modify Load Balancer (LB) or Public IP Settings
❌ WRONG: Modify LB rule or outbound rule directly
✔ RIGHT: Modify via AKS API

Example: Configuring LB idle timeout
```
az aks update -g <rg> -n <cluster> --load-balancer-idle-timeout 4
```

---

### 5.4 Create Internal Load Balancer
❌ WRONG: Create LB manually
✔ RIGHT: Use Kubernetes Service annotation

```
service.beta.kubernetes.io/azure-load-balancer-internal: "true"
```

---

### 5.5 Removing Public LB / Public IP
❌ WRONG: Delete LB or PIP manually
✔ RIGHT: Change outboundType to UDR

---

## 6. NRG Lockdown Feature
NRG Lockdown prevents users from modifying NRG resources directly.

Modes:
- **Unrestricted** (default earlier): allows direct modifications
- **ReadOnly**: denies deletion and modification

### 6.1 How ReadOnly Works
Applies a **Deny Assignment** to the NRG:
- Blocks actions for ALL principals
- Except AKS managed identity → allowed

### 6.2 Benefits of ReadOnly Mode
- Prevents accidental deletion of VMSS, LB, PIP
- Prevents unsupported modifications
- Ensures stable & supported AKS environment

---

## 7. Enabling NRG Lockdown (Preview)
```
az aks update -g <rg> -n <cluster> --node-resource-group-lockdown-mode ReadOnly
```

After enabling:
- Portal-based deletion attempts fail
- Manual LB/PIP changes fail
- Only AKS API can modify
