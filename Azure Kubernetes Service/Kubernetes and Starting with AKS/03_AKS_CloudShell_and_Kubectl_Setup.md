# 3. AKS Cloud Shell & Kubectl Setup

## Tools Required
Install:
- Azure CLI
- kubectl
- kube-login plugin

---

## Installing Azure CLI
Supported on:
- Windows
- Linux
- macOS
- WSL

---

## Installing kubectl
### Method 1 — Azure CLI (recommended)
```
az aks install-cli
```
Installs:
- kubectl
- kube-login plugin

### Method 2 — Manual installation
Via Kubernetes docs.

---

## Azure Cloud Shell (Browser-Based Terminal)
Cloud Shell includes:
- Azure CLI
- kubectl
- Terraform
- Git

### How to Open Cloud Shell
Azure Portal → Cloud Shell icon.
Requires storage account on first use.

---

## Connecting Cloud Shell to AKS Cluster
### Step 1 — Set subscription
```
az account set --subscription <ID>
```
### Step 2 — Get cluster credentials
```
az aks get-credentials --resource-group <RG> --name <CLUSTER>
```

Run tests:
```
kubectl get nodes
kubectl get pods -A
```

---

## Viewing Kubernetes Resources in Portal
Sections:
- Namespaces
- Pods
- Deployments
- ReplicaSets
- StatefulSets
- DaemonSets
- Jobs / CronJobs
- Services
- ConfigMaps & Secrets

Portal allows:
- Live logs
- YAML view
- Events
