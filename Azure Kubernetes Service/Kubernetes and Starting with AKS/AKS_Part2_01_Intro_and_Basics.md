📘 AKS Course — Part 2 Notes (With Terminology Explanations)

1. Introduction to Kubernetes (K8s)
What is Kubernetes?
Kubernetes is an open-source container orchestrator.
The word comes from the Greek word “Helmsman” meaning one who steers a ship (like a container ship).
It automates:

Deployment of containers
Scaling of applications
High availability
Load balancing
Resource allocation
Automated rollouts & rollbacks

What does “K8s” mean?
It is shorthand for Kubernetes:

“K” + 8 letters + “s”

Why do we need Kubernetes?
Running one or two containers manually is easy.
Running hundreds or thousands, across multiple servers, with:

Auto-scaling
Self-healing
Zero-downtime deployments

…requires a system like Kubernetes.

2. Kubernetes Cluster Basics
A Kubernetes cluster consists of:
a) Control Plane (Master Nodes)
This is the “brain” of the cluster.
It manages:

Desired state
Scheduling pods
Monitoring nodes
Kubernetes objects
Communications
Cluster-wide decisions

What is a Node?
A node is a VM or physical machine inside the cluster.
Two types:

Master node / Control plane node → manages cluster
Worker node / Data plane node → runs your applications (pods)

What is a Pod?
A pod is the smallest unit in Kubernetes.
You cannot run a container directly — it must run inside a pod.
A pod:

Can contain one or more containers
Shares:

Same network namespace
Same IP address
Same storage

Multiple containers inside a pod communicate via localhost.

What is a Deployment?
A deployment manages the lifecycle of pods.
With a deployment you define:

How many replicas you want
Update strategy
Rollbacks

Deployments automatically create a ReplicaSet, which ensures the correct number of pods always exist.

What is a Service?
Kubernetes service = a stable way to access pods.
It:

Has its own IP (from Service CIDR)
Load-balances traffic
Provides stable networking even if pods restart
