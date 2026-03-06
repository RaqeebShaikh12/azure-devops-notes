# AKS Load Balancer, Route Tables & Support Policies – Detailed Notes (Part 2)

## 5. Route Table – How AKS Routes Pod Traffic
Route tables determine how packets exit subnets.

### 5.1 Why Route Tables Are Used
In **kubenet** networking mode:
- Pods get IPs from Pod CIDR
- Each node receives a Pod CIDR block

Example:
```
Node0 → 10.244.0.0/24
Node1 → 10.244.1.0/24
```

Routes:
```
10.244.0.0/24 → Node0
10.244.1.0/24 → Node1
```

### 5.2 Demonstration Summary
- Viewed automatic routes
- Confirmed pod IPs matched node CIDR assignments
- Verified route table directs traffic correctly

---

## 6. Azure Support Policies for AKS – Critical Notes
Understanding support boundaries is essential.

### 6.1 What Microsoft Manages
- Control plane components (API server, scheduler, etc.)
- CoreDNS
- Kube-proxy
- Kubelet patches
- Networking (if not BYO CNI)
- System components (metrics server, tunneling agents)

### 6.2 What You Manage
- Apps you deploy
- Kubernetes objects you create
- Third-party tools (NGINX, Istio, etc.)
- Custom networking setups
- BYO CNI setups

---

## 6.3 What You Must NOT Do (These Make Cluster Unsupported)
❌ Modify AKS node VMs directly:
- No resizing VM
- No changing VM extensions
- No OS-level changes
- No metadata edits

❌ Modify Azure resources managed by AKS:
- Load balancer
- NSG
- Public IP
- VMSS
- Route tables

❌ Block intra-subnet traffic via NSG

❌ Use unsupported Kubernetes versions

---

## 6.4 What Microsoft Support Won’t Cover
- Kubernetes usage questions
- Third-party tools
- Custom networking outside documentation
- Your own application bugs

---

## 7. Customer Responsibilities Summary
- Keep Kubernetes version supported
- Apply node OS image upgrades regularly
- Use DaemonSets for node tuning
- Do not stop/start nodes via VMSS or Azure Portal
- Use AKS APIs for scaling and size changes
- Avoid blocking internal VNet traffic

---

## 8. Final Overview
You now understand in detail:
- Load Balancer & Public IP behavior
- Managed identities
- VNet, Subnet, NSG
- Route Table
- Support boundaries and responsibilities

All these form the foundation of AKS infrastructure.

---
