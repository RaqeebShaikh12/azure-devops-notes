# Kubernetes Productivity Tools, Imperative vs Declarative, and Core Objects — Notes

## 1. Improving Productivity with kubectl
### 1.1 Autocompletion
- By default, terminals don’t autocomplete Kubernetes commands (e.g., `kubectl get po<TAB>`).
- Enable autocompletion:
```bash
source <(kubectl completion bash)
```
- Add same line to `~/.bashrc` to persist across terminal sessions.

### 1.2 Aliases
```bash
alias k=kubectl
alias kn='kubectl config set-context --current --namespace'
```
Usage examples:
- `k get pods`
- `kn kube-system`

---

## 2. VS Code Kubernetes Extensions
### 2.1 Kubernetes Extension
- Explore Kubernetes objects: namespaces, nodes, pods, deployments.
- Right-click operations: Describe, Apply, Delete.
- Auto-generate YAML templates using IntelliSense.

### 2.2 Azure Kubernetes Service Extension
- Integrated Azure tools: diagnostics, health checks, Periscope.
- Ability to run kubectl commands directly inside VS Code.

---

## 3. VS Code Trick: Run Selected Text in Terminal
- Open Keyboard Shortcuts → search *Terminal: Run Selected Text*.
- Assign hotkey (e.g., **Ctrl + R**).
- Select any command → press shortcut → runs instantly.

---

## 4. PowerShell Basics for Azure + Kubernetes
### 4.1 Connect to Azure
```powershell
Connect-AzAccount
Set-AzContext -Subscription "YourSubID"
```

### 4.2 AKS Module Installation Check
```powershell
Get-Module -ListAvailable Az.Aks
```

### 4.3 Create Resource Group + AKS Cluster
```powershell
New-AzResourceGroup -Name RGName -Location eastus
New-AzAksCluster -ResourceGroupName RGName -Name MyAKS -NodeCount 2
```

### 4.4 Fix SSH Folder Issue
```powershell
New-Item -ItemType Directory -Force -Path ~/.ssh
```

### 4.5 Import Cluster Credentials
```powershell
Import-AzAksCredential -ResourceGroupName RGName -Name MyAKS
```

---

## 5. Imperative vs Declarative Kubernetes
### 5.1 Imperative
“You tell Kubernetes *how* to do something.”
```bash
kubectl create deployment nginx --image=nginx --replicas=2
```
Dry run (generate YAML without creating):
```bash
kubectl create deployment nginx --image=nginx --replicas=2 --dry-run=client -o yaml
```

### 5.2 Declarative
“You define the desired state, Kubernetes figures out the rest.”
```bash
kubectl apply -f deployment.yaml
```

---

## 6. Kubernetes Objects Overview
- **Nodes** → run **Pods** → run **Containers**.
- **Deployments** → manage **ReplicaSets** → maintain desired Pod count.
- **DaemonSets** → ensure **one Pod per node**.
- **Services** → expose workloads (ClusterIP, NodePort, LoadBalancer).
- **Secrets** → store sensitive data (Base64 encoded).
- **ConfigMaps** → store non-sensitive configuration.
- **Namespaces** → logical isolation.

Diagram:
```
Nodes
 └── Pods
       └── Containers
Deployments
 └── ReplicaSets
       └── Pods
DaemonSets → 1 pod/node
Services → expose Pods
ConfigMaps → config
Secrets → sensitive data
```

---

## 7. Demo Summary
You created:
- A ConfigMap containing Python application code.
- A Secret storing an API key.
- A Deployment that:
  - mounts the ConfigMap as files,
  - injects the Secret as environment variables.
- A ClusterIP Service exposing the app internally.

Accessing service returns output like:
```
Hello World - API KEY: ABCXYZ
```

---

## 8. DaemonSets
- Used for node-level agents: monitoring, logging, networking.
- Guarantees **exactly 1 pod per node**.
- If a node is added → new pod created.
- If a node is removed → related pod removed.

---

