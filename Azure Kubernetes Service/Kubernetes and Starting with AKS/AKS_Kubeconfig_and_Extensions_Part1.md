
# AKS Kubeconfig, Cluster Switching, and Context Management — Detailed Notes (Part 1)

## 1. Understanding `az aks get-credentials`
The command `az aks get-credentials` downloads Kubernetes authentication information for your AKS cluster and merges it into your local kubeconfig file located at:
```
~/.kube/config
```
This process:
- Retrieves the **cluster CA certificate**, **client certificate**, **client key**, and **API server endpoint**.
- Merges these details into existing kubeconfig if present.
- Sets the newly added cluster as the current context (unless otherwise specified).

It allows `kubectl` to communicate with the AKS control plane securely.

---

## 2. What Is a Kubeconfig File?
A kubeconfig file contains all authentication and cluster-access information for `kubectl`. It consists of:

### 🔹 **clusters**
Defines Kubernetes clusters you can connect to.
Example:
```
clusters:
- name: aks-cluster1
  cluster:
    server: https://myaks1.hcp.eastus.azmk8s.io
    certificate-authority-data: <base64>
```

### 🔹 **users**
Defines the credentials used to authenticate.
```
users:
- name: clusterUser_aks1
  user:
    client-certificate-data: <base64>
    client-key-data: <base64>
```

### 🔹 **contexts**
A **context = cluster + user + namespace**.
```
contexts:
- name: aks1
  context:
    cluster: aks-cluster1
    user: clusterUser_aks1
    namespace: default
```

### 🔹 **current-context**
Determines which cluster `kubectl` talks to by default.
```
current-context: aks1
```

---

## 3. Working with Multiple AKS Clusters
Once multiple clusters are added via `get-credentials`, your kubeconfig contains multiple contexts.

### Show current context:
```
kubectl config current-context
```

### List all contexts:
```
kubectl config get-contexts
```

### Switch between clusters:
```
kubectl config use-context <context>
```
Example:
```
kubectl config use-context aks2
```

---

## 4. Practical Demo Summary
You:
- Viewed kubeconfig
- Ran `get-credentials` for two clusters
- Verified multiple contexts
- Switched between contexts using:
  - `kubectl config use-context`
  - VS Code Kubernetes Extension
- Verified each cluster with pod listings

---

## 5. VS Code Kubernetes Extension
The VS Code extension allows:
- Visual switching between contexts
- Browsing namespaces
- Viewing pods, services, deployments
- Right-click actions such as describe, delete, exec

This is highly useful when working with multiple clusters.

---
