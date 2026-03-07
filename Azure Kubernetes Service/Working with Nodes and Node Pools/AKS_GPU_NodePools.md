# AKS GPU Node Pools – Detailed Notes (Chunk 2)

Hello and welcome to this lecture about GPU.

Graphical processing units or GPUs are frequently used for workloads that need a lot of computation like graphics and visualization workloads.

Generally speaking, in Azure GPU optimized V-series start with **N** (N-series). For AKS node pools, a **minimum VM size of Standard_NC6** is recommended.

It is advised to add a **taint** during node pool creation to make scheduling on GPU nodes easier to control:
```
--node-taints sku=gpu:NoSchedule
```

There are **two methods** to enable GPU usage in AKS:

---
## Method 1 — Using the GPU Image (Preview Feature)
Requires:
- Registering the GPU dedicated preview feature flag
- Installing the Azure CLI preview extension
- Using custom headers:
```
--aks-custom-headers UseGPUDedicatedVHD=true
```
- For Gen2 VM sizes:
```
--aks-custom-headers UseGPUDedicatedVHD=true,UseGen2VM=true
```

Microsoft documentation strongly recommends following the official instructions.

---
## Method 2 — Manually Installing the NVIDIA Device Plugin (Used in our Demo)
Steps:
1. Create a GPU node pool with a GPU VM size (e.g., Standard_NC6)
2. Deploy the NVIDIA Device Plugin DaemonSet

This installs:
- Necessary GPU drivers
- GPU support libraries
- Scheduler hooks to expose GPU capacity

> Important: If you use Method 1, **do NOT install this DaemonSet manually**.

---
## Hands-On Demo
### Step 1 — Create GPU Node Pool
```
az aks nodepool add --name gpu --node-vm-size Standard_NC6
```
Node pool successfully created.

### Step 2 — Create Namespace for GPU Resources
```
kubectl create namespace gpu-resources
```

### Step 3 — Apply NVIDIA Device Plugin DaemonSet
You created `nvidia.yaml` from Microsoft docs and applied it:
```
kubectl apply -f nvidia.yaml
```
The DaemonSet installed one pod per node.

### Step 4 — Validate GPU Availability
```
kubectl describe node <gpu-node> | grep -i -e capacity -e accelerator
```
Output showed:
```
Capacity:
  nvidia.com/gpu: 1
```
This confirms the node exposes **1 GPU**.

---
## Step 5 — Run a GPU-Enabled Workload
You applied a test GPU job from Microsoft documentation:
```
kubectl apply -f gpu-job.yaml
```
You monitored:
```
kubectl get job
kubectl get pods
kubectl logs <pod-name>
```
The job completed successfully and produced NVIDIA CUDA test output.

---
## Step 6 — Cleanup
Because GPU VMs are expensive, you deleted:
- GPU node pool
- GPU DaemonSet
- The GPU job

Commands used:
```
kubectl delete -f nvidia.yaml
kubectl delete job <job-name>
az aks nodepool delete --name gpu
```

---
## Summary
You successfully learned:
- When to use GPU nodes
- How GPU VM sizes work in Azure
- How to deploy GPU-enabled AKS node pools
- How to install the NVIDIA device plugin manually
- How to run GPU workloads
- How to clean up GPU resources to avoid unnecessary cost

GPU support in AKS is powerful and easy to enable once you understand the setup.

Thank you for watching and see you in the next one!
