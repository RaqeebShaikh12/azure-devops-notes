# AKS Detailed Notes — Part 1

## 1. Introduction to Kubernetes (K8s)
What is Kubernetes?
Kubernetes is an open-source container orchestrator.
The word comes from the Greek word “Helmsman” meaning one who steers a ship (like a container ship).
It automates:

- Deployment of containers
- Scaling of applications
- High availability
- Load balancing
- Resource allocation
- Automated rollouts & rollbacks

### What does “K8s” mean?
It is shorthand for Kubernetes:
- “K” + 8 letters + “s”

### Why do we need Kubernetes?
Running one or two containers manually is easy.
Running hundreds or thousands, across multiple servers, with:
- Auto-scaling
- Self-healing
- Zero-downtime deployments

…requires a system like Kubernetes.

## 2. Kubernetes Cluster Basics
A Kubernetes cluster consists of:

### a) Control Plane (Master Nodes)
This is the “brain” of the cluster.
It manages:
- Desired state
- Scheduling pods
- Monitoring nodes
- Kubernetes objects
- Communications
- Cluster-wide decisions

### What is a Node?
A node is a VM or physical machine inside the cluster.
Two types:
- Master node / Control plane node → manages cluster
- Worker node / Data plane node → runs your applications (pods)

### What is a Pod?
A pod is the smallest unit in Kubernetes.
You cannot run a container directly — it must run inside a pod.
A pod:
- Can contain one or more containers
- Shares:
  - Same network namespace
  - Same IP address
  - Same storage

Multiple containers inside a pod communicate via **localhost**.

### What is a Deployment?
A deployment manages the lifecycle of pods.
You define:
- How many replicas you want
- Update strategy
- Rollbacks

Deployments automatically create a **ReplicaSet**, which ensures the correct number of pods exist.

### What is a Service?
A Kubernetes Service is a stable way to access pods.
It:
- Has its own IP (from Service CIDR)
- Load-balances traffic
- Provides stable networking even if pods restart

## 3. Kubernetes Architecture (Deep Dive)

### 3.1 Control Plane Components

#### 📌 a) Etcd — “The Database of Kubernetes”
Stores all cluster state including:
- Nodes
- Pods
- Services
- Secrets
- ConfigMaps
- Cluster configuration

When you run:
```
kubectl get <anything>
```
You are reading from Etcd via the API server.

#### 📌 b) API Server — “The Front Door of Kubernetes”
Handles:
- HTTPS Kubernetes API
- Request validation
- Authentication
- Authorization
- Updates Etcd
- Communicates with control plane + worker nodes

Every request from kubectl, controllers, schedulers, and kubelet passes through the API server.

#### 📌 c) Controller Manager — “Maintains Desired State”
Contains controllers like:
- Node controller
- Replication controller
- Deployment controller

If a pod crashes, controller manager recreates it.

#### 📌 d) Scheduler — “Decides Where Pods Run”
The scheduler:
- Looks for unscheduled pods
- Selects the best node based on:
  - CPU/RAM availability
  - Pod resource requests
  - Taints / tolerations
  - Affinity rules
  - Storage / topology

Example:
A pod needs **3GB RAM**.
Nodes:
- A: 2GB free → ❌ cannot schedule
- B: 4GB free → possible
- C: 6GB free → best choice

Scheduler picks **Node C**.

#### 📌 e) Cloud Controller Manager
Used only in cloud, e.g., Azure.
Handles:
- Load balancers
- Public IPs
- Storage
- VM lifecycle

### 3.2 Worker Node Components

#### 📌 a) Kubelet — “The Node Agent”
Ensures containers are running inside pods.
Reports node & pod status to API server.
Communicates with container runtime.

#### 📌 b) Container Runtime (containerd in AKS)
Runs containers.
Examples:
- Docker
- containerd
- CRI‑O

Runtime:
- Pulls images
- Starts containers
- Manages storage & networking

#### 📌 c) Kube‑proxy — “Network Traffic Manager”
Handles:
- IPTables/IPVS rules
- Load-balancing
- Pod-to-pod routing
- Service routing

If you create a Service:
Kube-proxy forwards traffic to the correct pod.
