# AKS Disk Types, Default Disk Size Logic & Behavior — Detailed Notes (Part 3)

## 10. Disk Types: Managed vs Ephemeral
### Managed Disks
- Persistent
- Azure Storage backed
- Slightly slower
- Best for persistent storage use cases

### Ephemeral Disks
- Stored on VM cache
- Non‑persistent
- Faster scaling & provisioning
- Lower latency
- Cheaper (included in VM price)

## 11. Example Node Pools
You created two node pools:
- Ephemeral OS disk 30GB → only ~2GB free
- Managed OS disk 30GB → full 32GB host storage

Inside node shells you verified disk behavior.

## 12. Default OS Disk Size Logic
AKS determines OS disk size based on **vCPU count** when size not specified.
Example mapping:
- 1–7 vCPUs → P10 (128GB)
- etc.

Your node size: **2 vCPUs**
Default OS disk: **120GB** (verified in Portal).

---

These notes include: scheduling methods, LTSC rules, kubelet customization, daemonset modifications, disk types, and default OS disk selection rules.
