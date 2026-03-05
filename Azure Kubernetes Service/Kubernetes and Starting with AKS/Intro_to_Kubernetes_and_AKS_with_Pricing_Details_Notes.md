# Introduction to Kubernetes and Azure Kubernetes Service (AKS) — With Pricing Details

## 1. What is Kubernetes?
Kubernetes (often abbreviated as **K8s**) is an **open‑source container orchestration platform** designed to automate:
- Deployment of containers
- Scaling applications
- High availability
- Load balancing
- Resource management
- Automated rollouts/rollbacks

### Why the name K8s?
The name "Kubernetes" comes from the Greek word for **helmsman** (someone who steers a ship). 
K8s is shorthand because there are **8 letters between K and s**.

### Why Kubernetes Exists
Manually running a few containers is easy, but managing **hundreds or thousands** across multiple servers requires automation. Kubernetes solves problems such as:
- Automatic failover
- Self‑healing (restart failed pods)
- Zero‑downtime deployments
- Declarative configuration
- Cluster‑aware networking

---

## 2. Kubernetes Cluster Architecture (Explain Like I'm 12)
A Kubernetes cluster is split into two main sections:

### **A) Control Plane (Master Nodes)** — *The Brain*
Components here maintain the “desired state” of the cluster.

- **API Server** — The entry point for all requests into Kubernetes.
- **etcd** — A distributed key‑value database that stores cluster state.
- **Scheduler** — Decides which node will run each pod.
- **Controller Manager** — Ensures reality matches desired state.
- **Cloud Controller Manager** — Connects Kubernetes to cloud APIs.

### **B) Worker Nodes (Data Plane)** — *The Muscles*
These machines actually run your applications.

Components:
- **Kubelet** — Ensures containers defined in pods are running.
- **Container Runtime (containerd in AKS)** — Executes containers.
- **Kube‑proxy** — Handles networking & routing to pods.

---

## 3. Key Kubernetes Objects (Beginner‑Friendly Definitions)
### **Pod**
The smallest deployable Kubernetes unit.
A pod may contain **one or more containers**, sharing:
- Same IP
- Same storage
- Same network namespace

### **Deployment**
Controls how pods behave. Allows you to specify:
- Replica count
- Update strategy
- Rollbacks

Deployments automatically create **ReplicaSets**, which ensure the correct number of pods always exist.

### **Service**
Provides stable networking to pods using:
- A dedicated IP (from Service CIDR)
- Load balancing

Used because pod IPs change frequently.

---

## 4. What is AKS (Azure Kubernetes Service)?
AKS is Microsoft Azure’s **managed Kubernetes service**. 
This means Azure handles the hardest parts of Kubernetes for you.

### What Azure Manages (FREE Control Plane)
- API Server
- etcd
- Scheduler
- Controller Manager
- Certificates
- Automatic control‑plane upgrades
- High‑availability of master components
- Health monitoring

### What YOU Manage
- Worker nodes (VMs)
- Applications (pods)
- Deployments, Services, Ingress
- Networking configuration
- Node OS image upgrades
- Add-ons (monitoring, ingress controllers, etc.)

### Why AKS is Popular
- Production‑grade Kubernetes in minutes
- Zero control‑plane maintenance
- Azure AD Integration & RBAC
- Autoscaling features
- ACR (Azure Container Registry) integration
- Monitoring with Azure Monitor
- Excellent for microservices workloads

---

## 5. Azure Pricing — The Basics
Azure offers multiple pricing models:

### **1. Pay‑As‑You‑Go**
- Default plan
- No commitment
- Highest hourly rate
- Best for learning and development

### **2. Reserved Instances (1 or 3 years)**
Save money by committing to specific VM sizes.
- 1 year → ~48% savings
- 3 years → ~65% savings

### **3. Spot Instances**
Use unused Azure capacity at huge discounts.
- Up to **90% cheaper**
- Can be removed (evicted) anytime
- **NOT recommended for production**

### **Region‑Based Pricing**
Different regions have different prices.
Example: West Europe vs East US.

---

## 6. AKS Cost Structure (Very Important)
AKS pricing is unique because the **control plane is FREE**.

### ✔️ **AKS Control Plane — $0**
Unless you choose the optional paid tier.

### ✔️ You pay for:
1. **Worker Node VMs** (biggest cost)
2. **Node OS Disks**
3. **Persistent Volumes (Azure Managed Disks)**
4. **Load Balancers**
5. **Public IPs**
6. **Azure Monitor / Log Analytics**
7. **Optional Add‑Ons** (Ingress Controller, Firewalls, ACR storage)

### ✔️ Optional Paid Tier: Uptime SLA (Standard Tier)
- 99.95% uptime (with availability zones)
- 99.9% without zones
- Cost: **$0.10 per cluster per hour**
- Recommended for production

---

## 7. Cost Optimization Strategies for AKS

### **1. Choose the Right VM Size**
- System node pools must have ≥ **2 vCPUs**
- Avoid burstable B‑series for system pools
- Use cheaper VM sizes for dev environments

### **2. Enable Cluster Autoscaler**
Autoscaler automatically:
- Adds nodes when needed
- Removes empty nodes to save money

### **3. Stop/Start AKS Cluster
When Not in Use**
- Save compute cost
- State preserved for 12 hours
- Ideal for learning and development

### **4. Use Spot Node Pools**
- Up to 90% cheaper
- Good for batch jobs or dev workloads
- NOT for production‑critical pods

### **5. Use Virtual Nodes (ACI)**
- Pods run in Azure Container Instances
- Pay per second
- Instant scaling for burst workloads

### **6. Monitor Your Costs**
Use Azure Cost Analysis to track expenses:
- Load balancers
- Public IPs
- Node pools
- Disk usage
- Log Analytics (can grow expensive)

### **7. Use Free Tier Unless in Production**
Free Tier → No control plane cost.
Standard Tier → Paid, but needed for serious production workloads.

---

## 8. Summary
This section introduced:
- Kubernetes fundamentals (pods, deployments, services)
- Kubernetes architecture (control plane + workers)
- What AKS is and why it’s useful
- Azure pricing models (Pay‑As‑You‑Go, Reserved, Spot)
- AKS cost structure (free control plane!)
- Cost-saving strategies for running AKS efficiently

AKS gives you enterprise‑grade Kubernetes with minimal operational overhead, making it ideal for modern cloud‑native applications.

---

*End of notes.*
