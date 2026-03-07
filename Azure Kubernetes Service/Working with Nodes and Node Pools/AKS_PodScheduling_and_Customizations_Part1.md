# AKS Pod Scheduling, Windows LTSC Compatibility & Node Selectors — Detailed Notes (Part 1)

## 1. Pod Scheduling & LTSC Image Compatibility
Windows containers MUST match the Windows node OS version:
- ltsc2019 → runs ONLY on Windows Server 2019 nodes
- ltsc2022 → runs ONLY on Windows Server 2022 nodes
If you mismatch, pods enter `ImagePullBackOff` or `ErrImagePull`.

## 2. Checking Node OS Version
Portal → AKS → Node Pools → OS SKU
Or:
```
kubectl get nodes -o custom-columns="Node Name:.metadata.name,OS Image:.status.nodeInfo.osImage"
```

## 3. Labels and Scheduling Logic
You inspected labels using:
```
kubectl describe node <name>
```
Labels include:
- `kubernetes.io/os=windows`
- `kubernetes.io/os=linux`
- `agentpool=<poolname>`

## 4. Scheduling Linux Pods
YAML:
```yaml
spec:
  nodeSelector:
    agentpool: nodepool1
```
All nginx pods now scheduled ONLY on Linux nodes.

## 5. Scheduling Windows Pods
YAML:
```yaml
spec:
  nodeSelector:
    kubernetes.io/os: windows
```
Uses image:
```
mcr.microsoft.com/windows/servercore:ltsc2019
```
Ensures Windows pods run ONLY on Windows node pool.
