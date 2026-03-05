# Full Introduction to Kubernetes and AKS — Complete Notes (All 12 Sections)

## 1. What is Kubernetes (K8s)?
Kubernetes is an **open‑source container orchestration platform** that automates deploying, scaling, and operating containerized applications. The name comes from the Greek word meaning *helmsman*. "K8s" is shorthand for Kubernetes because there are 8 letters between the K and s.

Kubernetes provides:
- Self‑healing (restart crashed containers)
- Horizontal scaling
- Load balancing
- Automated rollouts & rollbacks
- Service discovery & networking
- Declarative configuration

---

## 2. Why Kubernetes Exists — The Problem It Solves
Running a few containers with Docker is easy. But running **hundreds or thousands** across multiple machines becomes nearly impossible manually.

Kubernetes solves problems like:
- How do containers communicate across machines?
- How do we replace failed containers automatically?
- How do we scale applications under load?
- How do we update applications without downtime?
- How do we manage multiple containerized microservices at scale?

---

## 3. Kubernetes Architecture (Control Plane + Worker Nodes)
Kubernetes clusters have two major parts:

### A) **Control Plane (Master Nodes)** — The “Brain”
Responsible for the desired state of the cluster.

Components:
- **API Server**: The front door of the cluster; validates requests.
- **etcd**: Distributed key‑value store that keeps all cluster state.
- **Scheduler**: Decides on which node new pods should run.
- **Controller Manager**: Ensures actual state matches desired state.
- **Cloud Controller Manager**: Cloud‑specific actions (Azure LB, IPs, disks).

### B) **Worker Nodes (Data Plane)** — The “Muscles”
Hosts your application containers.

Components:
- **Kubelet**: Ensures containers defined in pods are running.
- **Container Runtime (containerd in AKS)**: Actually runs containers.
- **Kube‑proxy**: Handles routing & service networking.

---

## 4. Core Kubernetes Objects
### **Pod**
Smallest deployable unit. Runs one or more containers with shared IP, storage, and network.

### **Deployment**
Manages replicas, rolling updates, and rollback.

### **ReplicaSet**
Ensures the correct number of pod replicas exist.

### **Service**
Stable networking component that exposes pods using a single IP.

### **Node**
Worker machine (VM or physical) that runs pods.

---

## 5. What Happens When You Create a Pod? (Step‑by‑Step)
1. Developer runs `kubectl apply -f pod.yaml`.
2. kubectl converts YAML → JSON and sends to API Server.
3. API Server:
   - Authenticates
   - Authorizes
   - Validates
   - Stores configuration in etcd
4. Scheduler sees an unscheduled pod → picks a node.
5. Scheduler updates API Server → API Server updates etcd.
6. Kubelet on selected node receives pod specs → instructs container runtime.
7. Container runtime pulls image → runs container.
8. Kubelet reports status back to API Server → etcd.

---

## 6. How Users Access Applications in the Cluster
Pods are ephemeral, so we use a **Service**.

If we create a `Service type=LoadBalancer`:
- Kubernetes asks the cloud provider to create a **public load balancer**.
- Azure assigns a **public IP**.
- Kube‑proxy configures routing so traffic reaches pods.

Users access the application using the load balancer's public IP.

---

## 7. What is AKS (Azure Kubernetes Service)?
AKS is a **fully managed Kubernetes service** provided by Microsoft Azure.

### Azure Manages (Control Plane — FREE)
- API server
- Scheduler
- etcd
- Controller manager
- Cloud integrations
- Patching, upgrades, health monitoring

### YOU Manage (Worker Nodes)
- Node pools (VMs)
- Pod deployments/apps
- Networking configs
- OS upgrades for nodes
- Add‑ons (ingress, monitoring)

### Benefits of AKS
- Easy cluster creation (minutes)
- Managed control plane
- Integration with Azure AD, RBAC
- Autoscaling, monitoring
- Integration with Azure ecosystem (VNet, LB, ACR, Key Vault)

---

## 8. Azure Pricing Basics
Azure offers multiple pricing models:

### 1. **Pay‑As‑You‑Go**
- Highest hourly rate
- No commitment
- Recommended for learning

### 2. **Reserved Instances (1 or 3 years)**
- Up to 65% cheaper
- You commit to VM types

### 3. **Spot Instances**
- Uses unused Azure capacity
- Up to 90% cheaper
- Can be evicted anytime → not for production

### Region‑based pricing
Different Azure regions have different costs.

---

## 9. Azure Free Account
Azure free tier offers:
- **$200 credit for 30 days**
- Free services for 12 months
- Some services always free

AKS control plane is **ALWAYS FREE**.

---

## 10. AKS Cost Structure (Very Important)
AKS pricing is unique:

### ✔️ AKS Control Plane — **Free**
You only pay for:
- Worker node VMs
- OS disks
- Persistent volumes (managed disks)
- Load balancers
- Public IPs
- Log Analytics / Monitoring
- Optional add‑ons

### Optional Paid Control Plane Tier: Standard
- 99.95% SLA (with zones)
- 99.9% SLA (without zones)
- Cost: $0.10 per hour
- Recommended for production

---

## 11. Cost Optimization Strategies for AKS
### **1. Choose right VM sizes**
System node pool requires:
- ≥ 2 vCPUs
- ≥ 4 GB RAM
Avoid B‑series for system pool.

### **2. Use Cluster Autoscaler**
Automatically adds nodes when needed and removes unused nodes.

### **3. Stop/Start AKS cluster when not needed**
- Saves node compute cost
- State preserved for 12 hours

### **4. Use Spot node pools**
Great for:
- CI/CD
- Testing
- Batch jobs
Not suitable for production.

### **5. Use Virtual Nodes (ACI)**
- Instantly burst scale
- Pay per‑second

### **6. Monitor costs**
Log Analytics can become expensive → tune retention.

### **7. Choose Free Tier for dev; Standard Tier for prod**
Use Free Tier while learning.

---

## 12. Summary
You learned:
- Kubernetes fundamentals
- Kubernetes architecture
- Pod creation flow
- Load balancing via Services
- What AKS is and why it matters
- Azure pricing models
- AKS cost structure (control plane is free!)
- Cost optimization best practices

This prepares you to start deploying clusters in AKS with confidence.

*End of comprehensive notes.*
