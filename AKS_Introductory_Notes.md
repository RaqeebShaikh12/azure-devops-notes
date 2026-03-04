# Azure Kubernetes Service (AKS) — Introductory Notes

## 1. What is Kubernetes?
Kubernetes (K8s) is an open-source container orchestration platform that automates:
- Deployment of containers
- Scaling
- Load balancing
- Self‑healing
- Rolling updates

It solves the challenges of running many containers across multiple servers.

---

## 2. What is Azure Kubernetes Service (AKS)?
AKS is Microsoft’s fully managed Kubernetes platform. Azure manages the **control plane**, while you manage the **worker nodes**.

### Benefits
- No control‑plane management
- Automatic upgrades & patching
- Tight Azure integration (ACR, VNET, RBAC)
- Enterprise-grade scaling and security

---

## 3. AKS Architecture Overview
```
AKS Control Plane (Managed by Azure)
 |-- API Server
 |-- Scheduler
 |-- etcd
 |-- Controller Manager

Node Pool (Your VMs / Scale Set)
 |-- Pod A
 |-- Pod B
 |-- Pod C
```

---

## 4. AKS Core Concepts
- **Node Pool** – a group of worker nodes
- **Pod** – smallest deployable unit
- **Deployment** – defines replica count + rolling updates
- **Service** – exposes pods to the network (ClusterIP, NodePort, LoadBalancer)
- **Ingress** – Layer 7 routing, domain-based routing
- **ConfigMap/Secret** – configuration & sensitive data

---

## 5. AKS Networking Models
### Kubenet
- Simpler
- Pods use overlay IPs
- Good for smaller clusters

### Azure CNI
- Pods receive VNet IPs
- Best for production
- Easier VNet integration

---

## 6. AKS Identity Options
- System-assigned managed identity
- User-assigned managed identity
- Kubelet identity (pulls images from ACR)

---

## 7. AKS + ACR Integration
To allow AKS to pull images from ACR, assign:
- **Role**: AcrPull
- **Principal**: Kubelet identity
- **Scope**: ACR resource ID

---

## 8. AKS Deployment Strategies
- Rolling updates
- Blue-Green deployments
- Canary deployments

---

## 9. AKS Storage Options
- Azure Disk (per pod)
- Azure Files (shared)
- Ephemeral OS (stateless workloads)

---

## 10. AKS Monitoring
Uses Azure Monitor + Container Insights for:
- CPU/memory
- Pod logs
- Node health
- Live logs

---

*End of notes.*
