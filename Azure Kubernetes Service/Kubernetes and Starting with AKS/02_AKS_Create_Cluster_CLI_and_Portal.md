# 2. Creating AKS Cluster (CLI and Portal)

## Resource Groups Explained
A Resource Group (RG) stores Azure resources.
AKS creates **another RG automatically** called **Infrastructure Resource Group**.

### Naming convention
```
MC_<RESOURCE_GROUP>_<CLUSTER_NAME>_<REGION>
```
Contains:
- VM Scale Set
- VNET
- Load Balancer
- Route Table
- NSG
- Managed Identity

Deleting AKS deletes this group.

---

## Create a Resource Group via CLI
```
az group create -n RG-AKS-Demo -l eastus
```

## Create AKS Cluster via CLI
```
az aks create   --resource-group RG-AKS-Demo   --name akscluster1   --node-count 2   --generate-ssh-keys
```
Notes:
- Default node count = 3
- SSH keys generated automatically

Find parameter defaults:
```
az aks create -h
```

---

## Creating an AKS Cluster via Azure Portal
Steps:
1. Azure Portal → AKS → Create
2. Choose RG
3. Preset: Dev/Test
4. Enter name
5. Region
6. Pricing Tier: Free
7. Disable auto-upgrade
8. Manual scaling
9. Networking defaults
10. Review + Create

---

## Exploring AKS Portal Sections
- **Overview** → basic cluster info
- **Activity Log** → all operations
- **RBAC Access** → permissions
- **Tags** → cost mgmt
- **Diagnose and Solve** → troubleshooting
- **Defender for Cloud** → security alerts
- **Kubernetes Resources** → Pods, Deployments, YAML, logs
- **Node Pools** → worker nodes
- **Networking** → VNET, LB, NSG
- **Monitoring** → logs & metrics
- **Resource Health** → cluster status
- **Support Requests** → create tickets

---

## Infrastructure Resource Group Contents
Contains:
- VMSS
- Public IP
- Load Balancer
- VNET
- NSG
- Route Table
- Managed Identity
