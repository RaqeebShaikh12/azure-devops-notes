# AKS Detailed Notes — Part 3

## 7. Self‑Managed Kubernetes vs Cloud‑Managed AKS

### ✔️ Creation Complexity
- ❌ Self‑managed → install manually
- ✔️ Cloud‑managed → cluster in minutes

### ✔️ Flexibility
- ✔️ Self‑managed → full customization
- ❌ Cloud‑managed → limited

### ✔️ Management Overhead
- ❌ Self‑managed → you manage everything
- ✔️ AKS → Azure manages control plane

### ✔️ Required Skill
- ❌ Self‑managed → deep expertise
- ✔️ AKS → easier

### ✔️ Security
AKS provides:
- Azure AD integration
- RBAC
- Automatic patching
- SOC/ISO/HIPAA compliance

### ✔️ Ecosystem Integration
- Azure LB
- Azure Firewall
- Azure Monitor
- Defender for Cloud
- ACR

### ✔️ Cost
- Control plane → **free**
- Pay only for worker nodes

### ✔️ Support
- Cloud → Azure support
- Self-managed → community

## 8. AKS Features & Benefits
- Fast cluster creation
- Managed control plane
- Auto/manual scaling
- Auto/manual upgrades
- High security
- Monitoring integration
- Full Azure ecosystem compatibility

## 9. What is AKS? (Fully Explained)
Azure Kubernetes Service (AKS) is a **fully managed Kubernetes platform**.
Azure manages:
- API Server
- Scheduler
- Controller Manager
- etcd
- Certificates
- Patching
- Availability

YOU manage:
- Worker nodes
- Node OS upgrades
- Applications
- Networking config
- Add-ons
- Security policies

Shared responsibility model.

## 10. Azure Free Account + Pricing Model
Azure Free Account:
- $200 credit for 30 days
- 12 months free services
- Some always free

Great for AKS because:
- Control plane → free
- Pay only for nodes, storage, LB, public IPs.

### Azure Pricing Models
1. **Pay‑As‑You‑Go** → highest cost
2. **Reserved Instances** → up to 65% savings
3. **Spot Instances** → up to 90% savings

Regions have different pricing.
