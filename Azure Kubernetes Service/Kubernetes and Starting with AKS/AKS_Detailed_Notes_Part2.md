# AKS Detailed Notes — Part 2

## 4. Pod Creation Flow (Step-by-Step)

### Step 1 — Developer runs:
```
kubectl create -f pod.yaml
```

### Step 2 — YAML → JSON
Kubernetes internally uses JSON.

### Step 3 — API Server receives request
- Validates YAML
- Checks authentication
- Checks RBAC authorization
- Writes pod definition to Etcd

### Step 4 — Scheduler selects a node
Scheduler:
- Picks suitable node
- Updates API server
- API server updates Etcd

### Step 5 — Kubelet creates pod
- API server notifies kubelet
- Kubelet calls container runtime
- Runtime pulls image + runs container

### Step 6 — Kubelet reports status
Kubelet → API server → Etcd → reflected in:
```
kubectl get pods
```

## 5. Deployment vs Pod
A Deployment:
- Creates ReplicaSet
- ReplicaSet maintains number of replicas
- Recreates missing pods

Ensures **high availability**.

## 6. How Users Access Applications via Service (LoadBalancer)
Pods:
- Restart
- Move between nodes
- Have dynamic IPs
→ Not reliable for direct access.

A Service type LoadBalancer:
1. Creates Azure Load Balancer
2. Assigns Public IP
3. Kube-proxy sets routing rules
4. Users access via LB IP
