# AKS Bastion Node Access & SSH Connectivity — Detailed Notes (Part 2)

## 6. Azure Bastion for Node Access
Azure Bastion is a managed PaaS offering that enables:
- Browser-based SSH/RDP
- No public IPs needed
- No agents required on nodes

### 6.1 Why Bastion?
Because AKS nodes **do not** have public IPs.
Without Bastion, you'd need:
- A jumpbox
- Manual SSH tunnels

Bastion simplifies secure access.

---

## 7. Steps to Use Bastion for AKS Nodes
### Step 1 — Create SSH key
```
ssh-keygen -t rsa -b 4096
```

### Step 2 — Update AKS cluster with public key
Using preview feature:
```
az aks update --ssh-key-value ~/.ssh/id_rsa.pub
```

### Step 3 — Create Azure Bastion Subnet
Subnet name **must** be:
```
AzureBastionSubnet
```

### Step 4 — Create Bastion resource
Portal → Create Bastion → Attach to VNet

### Step 5 — Connect to Node
Portal → VM Instance → Bastion → SSH
- Username: `azureuser`
- Auth: Private key

You successfully connected and executed commands:
```
hostname
sudo journalctl
ls -la /var/log
```

This proves Bastion provides **real SSH**, unlike kubectl debug (which uses ephemeral helper pods).

---

## 8. Clean-Up
You removed:
- Bastion resource
- Bastion Public IP
Because these incur costs.

---

## 9. Final Summary
You learned:
- VMSS vs VMAS differences
- System vs User node pools
- Taints, tolerations & scheduling rules
- How kubectl debug & nsenter access nodes
- How Azure Bastion provides secure SSH access

These concepts are essential for AKS cluster operations and node-level troubleshooting.

---
