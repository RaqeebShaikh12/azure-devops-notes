# AKS Detailed Notes — Part 4

## 11. AKS Cost Breakdown — What You Pay For
AKS Control Plane → **FREE**

### You pay for:
- Worker nodes (VMs)
- Managed disks
- Load balancers
- Public IPs
- Monitoring (Log Analytics)
- Optional add-ons

## 12. Cost Optimization Strategies

### 12.1 Choose the Right VM Size
- System pool → ≥ 2 vCPUs
- Avoid B-series for system pool
- User pools → can use burstable VMs

### 12.2 Use Cluster Autoscaler
Autoscaler:
- Adds nodes when needed
- Removes unused nodes

### 12.3 Stop/Start AKS Cluster
- Stop during unused hours
- Saves 100% compute
- State preserved for 12 hours

### 12.4 Use Spot Node Pools
Spot nodes:
- Up to 90% cheaper
- Not for critical workloads

### 12.5 Use Virtual Nodes (ACI)
Run pods in Azure Container Instances.
Benefits:
- Instant scale
- Pay per second
- No VM provisioning

### 12.6 Standard Tier Only for Prod
- Free tier → learning, testing
- Standard tier → SLA for production

### 12.7 Region Selection
Pick cheapest region near users.

### 12.8 Monitoring Cost Control
- Reduce retention
- Reduce log collection
- Exclude noisy namespaces
