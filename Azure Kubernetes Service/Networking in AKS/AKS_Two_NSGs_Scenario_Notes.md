# AKS — Two NSGs Scenario (Subnet NSG + VM NIC NSG) — FULL DETAILED NOTES

This document contains **fully detailed, non‑summarized, lecture‑style notes** explaining what happens when **two Network Security Groups (NSGs)** are involved in an Azure Kubernetes Service (AKS) setup—one at **subnet level** (custom, user-managed) and one at **VM NIC level** (AKS-managed).

---
# 1. Introduction
When you **bring your own VNet, Subnet, and NSG**, AKS will still create and attach **its own NSG** to the **network interfaces (NICs)** of AKS worker node VMs.

This results in:
- **NSG #1 (User-managed)** → applied at **Subnet level**
- **NSG #2 (AKS-managed)** → applied at **VM NIC level**

In this configuration, **both NSGs must allow traffic** for an inbound request to succeed.

If **either NSG blocks the traffic**, connectivity fails.

---
# 2. How Inbound Traffic Flows Through Two NSGs
When inbound internet traffic flows toward a LoadBalancer service:

```
Internet → Public IP → Azure Load Balancer → Subnet NSG → VM NIC NSG → Pod
```

### This means:
✔ Traffic must be allowed by **your custom subnet NSG**
✔ Traffic must also be allowed by **AKS-managed NIC NSG**

If the subnet NSG does **NOT** allow the LB port → **traffic is blocked BEFORE reaching the NIC NSG**.

This is the root cause of the issue demonstrated in the lecture.

---
# 3. Recreating the Scenario
You deploy:
```
kubectl create deploy nginx-nsgs --image=nginx
```
Then expose it:
```
kubectl expose deploy nginx-nsgs --port=80 --type=LoadBalancer
```

AKS provisions a Public IP and Load Balancer.

But when accessing the IP →
❌ **The site does not load**

---
# 4. Why It Worked Earlier (Single NSG Scenario)
In previous labs (without BYO networking):
- AKS manages both the subnet NSG and NIC NSG →
- It automatically adds an **Allow inbound 80** rule in both places.

So connectivity works immediately.

---
# 5. Why It Fails Now (Two NSGs Scenario)
When you bring your own subnet NSG:
- AKS **cannot** modify your custom NSG
- It **only adds rules inside the NIC NSG** (AKS-managed)

### This results in:
- NIC NSG → allows port 80 (correct)
- Subnet NSG → **does NOT allow** port 80 (missing rule)

Therefore inbound traffic fails.

---
# 6. Validating the Two NSGs in Azure Portal
Go to:
```
AKS → Properties → Infrastructure Resource Group → Node Resource Group → VM → Networking
```
You will see:
- **NSG #1 (Subnet level)** → your custom NSG (created earlier)
- **NSG #2 (NIC level)** → AKS-managed NSG

Inside NIC NSG:
✔ You will see the automatically added rule allowing port 80.

Inside custom Subnet NSG:
❌ **No rule exists** allowing port 80.
Hence traffic is blocked.

---
# 7. Fixing the Issue — Add Inbound Rule to Your Subnet NSG
You must **manually add the SAME inbound rule** in your custom NSG.

### Steps:
1. Open your custom subnet NSG
2. Add new inbound rule:
   - **Source**: Internet (Service Tag)
   - **Destination**: Public IP of the Service
   - **Protocol**: TCP
   - **Port**: 80
   - **Action**: Allow
   - **Priority**: 500 (or lower number to override higher rules)

After saving: Propagation takes ~10–30 seconds.

Then the site loads successfully.

---
# 8. Why AKS Cannot Update Your Custom NSG
Azure/AKS design principle:

> AKS only manages resources **that it owns**.

- It **owns NIC NSGs** → so it updates them
- It **does NOT own your subnet NSG** → so it does NOT change it

This is to avoid unintended modification of enterprise-controlled security boundaries.

---
# 9. Key Takeaway
When using **BYO networking**:
- You MUST manually ensure your NSG allows the ports your Kubernetes LoadBalancer needs.
- AKS will NOT modify or interfere with your custom NSG.
- You must duplicate the required inbound rules.

### Summary Diagram:
```
Internet
   |
Public IP
   |
Azure Load Balancer
   |
[Subnet NSG — YOURS]  <-- must allow 80
   |
[NIC NSG — AKS]       <-- AKS auto allows 80
   |
AKS Node → Pod
```

If Subnet NSG blocks traffic → entire chain fails.

---
# End of Full Detailed Notes
