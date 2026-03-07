# AKS Node Operating Systems — Linux, Azure Linux & Windows — Detailed Notes (Part 3)

## 1. Linux Options
### Ubuntu
- Ubuntu 18 → Default for Kubernetes ≤ 1.24
- Ubuntu 22 → Default for Kubernetes ≥ 1.25

Cannot choose 18 vs 22; version is tied to Kubernetes version.

### Azure Linux (Mariner)
- Lightweight
- Secure
- Faster patching
- Microsoft-hardened kernel
- RPM-based
- Package manager: **DNF**

Mariner will become the **default OS** for AKS.

---

## 2. Windows Options
- Windows Server 2019 (K8s ≤ 1.24)
- Windows Server 2022 (K8s ≥ 1.25)

Important rules:
- **AKS cannot run Windows-only** clusters
- A **Linux system node pool is mandatory**
- Windows node pools must be **user** type

---

## 3. Determining Node OS
```
kubectl get node -o wide
```
Or in Portal:
- Node Pool → OS → Image version

Or on the node:
```
cat /etc/os-release
```

---

## 4. Creating Azure Linux Node Pool
You ran:
```
az aks nodepool add   --name marinerpool   --os-sku AzureLinux
```
Verified via:
```
kubectl get nodes -o wide
```
Inside node:
```
cat /etc/os-release
```

Installed packages using:
```
dnf install tcpdump
```

---

## 5. Creating Windows Node Pool
Prerequisite: **Azure CNI**

You updated cluster with Windows admin password:
```
az aks update --windows-admin-password <pwd>
```

Then added Windows node pool.

Connected to Windows node using SSH pod method:
```
ssh azureuser@<windows-node>
```
Used PowerShell inside:
```
powershell
```

---

## 6. Summary
You explored:
- Ubuntu OS variants
- Azure Linux (Mariner)
- Windows Server node pools
- OS detection methods
- Adding Linux & Windows node pools
- Accessing Windows nodes from Linux SSH pod

These OS choices determine cluster flexibility, security, and workload compatibility.
---
