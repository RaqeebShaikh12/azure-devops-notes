# AKS Kubelet & OS Customization — Detailed Notes (Part 2)

## 6. Kubelet & OS‑Level Customization
AKS allows customizing kubelet and OS settings ONLY during node pool creation.
Documentation provides:
- Parameter name
- Allowed values/range
- Defaults
- JSON examples

## 7. Viewing Default Kubelet Config
You ran:
```
kubectl proxy
curl localhost:8001/api/v1/nodes/<node>/proxy/configz
```
Example default:
```
imageGCHighThresholdPercent = 85
```

## 8. Creating Custom Kubelet Config
kubeletconfig.json:
```json
{
  "imageGCHighThresholdPercent": 90
}
```
Create node pool:
```
az aks nodepool add --kubelet-config kubeletconfig.json
```
Verification confirmed the value was updated.

## 9. DaemonSet-Based Node Customization
You needed to modify:
```
vm.max_map_count
```
Default:
```
65530
```
You deployed a privileged DaemonSet running:
```
sysctl -w vm.max_map_count=65540
```
After applying:
```
vm.max_map_count = 65540
```
These changes persist on nodes.
