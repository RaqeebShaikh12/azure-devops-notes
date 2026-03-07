# AKS SSH Pod Method & Run Command Invoke — Detailed Notes (Part 1)

## 1. SSH Pod Method to Access AKS Nodes
Throughout this lecture, we learned how to create a simple pod that allows SSH access into AKS nodes without needing Azure Bastion or additional Azure resources.

### Why This Method?
Unlike Azure Bastion, which requires:
- An extra subnet
- A Bastion resource (paid service)

This SSH pod method:
- Costs **nothing extra**
- Works entirely inside the cluster
- Provides **real SSH access** to the nodes

---

## 2. Requirements
- SSH key pair
- Nodes updated with the **public** SSH key
- Pod running a base image where we manually install SSH tools

This pod can run on ANY node. It can SSH into ALL nodes because **intra-subnet traffic is allowed**.

---

## 3. SSH Pod YAML Explanation
The pod uses:
- `postStart` lifecycle hook to install tools:
  - openssh-client
  - vim
  - sshpass
- `nodeSelector` to ensure scheduling on Linux nodes

The hook runs:
```
apt-get update && apt-get install openssh-client vim sshpass -y
```
This ensures the pod only starts running **after tools are installed**.

---

## 4. Steps Performed
### Step 1 — Create SSH Pod
You applied the YAML and created the pod.

### Step 2 — Copy SSH Private Key Into Pod
Using:
```
kubectl cp ~/.ssh/id_rsa <pod>:/root/.ssh/id_rsa
```

### Step 3 — Exec Into Pod
```
kubectl exec -it <pod> -- bash
```

### Step 4 — SSH Into Node
Initial error:
- Connected with **root** which failed

Fix:
Use Azure default node username:
```
ssh azureuser@<node-name>
```

Success:
- Connected via SSH
- Verified with `hostname`
- Inspected logs

This demonstrated **real SSH connectivity**.

---

## 5. Notes
- Pod can live permanently in the cluster
- Acts like a jumpbox **inside Kubernetes**
- Zero Azure cost
- Works on any cluster size

---

## 6. Summary
Using an SSH pod is a fast, cost-efficient, and powerful method to connect to AKS nodes inside the subnet.
