# AKS NRG Lockdown, Fixing Mistakes, Stop/Start Feature – Detailed Notes (Part 2)

## 8. Testing NRG Lockdown
After enabling lockdown:
- Delete VMSS → fails
- Modify LB idle timeout directly → fails
- Modify outbound rule → fails

But AKS operations still succeed:
- `az aks update`
- Creating/Deleting node pools
- Exposing services
- Scaling via AKS

---

## 9. Fixing Mistakes After Deployment
If you made unsupported changes:

### 9.1 Option 1 — Perform Correct Action
Use AKS or Kubernetes API to apply config.
Correct change overrides incorrect state.

### 9.2 Option 2 — Reconcile Cluster
```
az aks update -g <rg> -n <cluster>
```
Forces AKS to restore desired state.

### 9.3 Option 3 — Stop/Start Cluster
Triggers recreation of nodes.

### 9.4 Option 4 — Contact Microsoft Support
For highly broken states.

---

## 10. AKS Stop / Start Feature — Detailed Notes
Stopping AKS lets you save costs when cluster is not in use.

### 10.1 What Happens When You Stop AKS
- Control plane stops → API server unreachable
- VMSS instances are **deprovisioned** (not deallocated)
- Full compute cost savings
- API Server IP may change after start
- Standalone pods are deleted

### 10.2 Maximum Stop Duration
**12 months** → after that, cluster state unrecoverable.

### 10.3 Standalone Pods Behavior
Standalone pods = pods not owned by Deployment/DaemonSet
Stopping cluster deletes them permanently.

### 10.4 How to Stop Cluster
Portal → AKS → Stop

Or CLI:
```
az aks stop -g <rg> -n <cluster>
```

### 10.5 How to Start Cluster
```
az aks start -g <rg> -n <cluster>
```

### 10.6 15-Minute Wait Rule
Recommended to wait 15 minutes between Stop → Start.

---

## 11. Practical Demonstration Summary
You showed:
- API server reachable before stop
- Nodes shown in VMSS
- After stop → VMSS instances disappear
- API server unreachable
- After start → new VMSS instances created
- Standalone pods removed
- Managed workloads restored (Deployments, DaemonSets)

---

## 12. Final Summary of the Entire Lecture
- AKS uses two resource groups: User RG + Node RG
- Node Resource Group must NOT be modified manually
- Direct actions break clusters and don’t persist
- Always use AKS API or Kubernetes API
- NRG Lockdown prevents accidental modifications
- Stop/Start helps save cost and fully recreates nodes
- Unsupported methods may push cluster into unrecoverable state

You now understand how to safely manage AKS infrastructure and avoid the most common operational pitfalls.

---
