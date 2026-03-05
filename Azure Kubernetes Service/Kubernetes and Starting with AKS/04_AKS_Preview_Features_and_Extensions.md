# 4. AKS Preview Features & Extensions

## Understanding Preview Features
Preview =
- Not fully GA
- Not production ready
- Requires extra setup

---

## Azure CLI Extension: aks-preview
Install:
```
az extension add --name aks-preview
```

Check installation:
```
az extension list --output table
```

Update:
```
az extension update --name aks-preview
```

---

## Registering Preview Features
Example: Vertical Pod Autoscaler

### Step 1 — Check status
```
az feature show   --namespace Microsoft.ContainerService   --name VPAPreview
```

### Step 2 — Register feature
```
az feature register   --namespace Microsoft.ContainerService   --name VPAPreview
```

### Step 3 — Wait until Registered
```
az feature show
```

### Step 4 — Refresh provider
```
az provider register --namespace Microsoft.ContainerService
```

---

## Summary Steps
1. Install aks-preview extension
2. Register preview feature
3. Refresh provider
4. Use ONLY for testing
