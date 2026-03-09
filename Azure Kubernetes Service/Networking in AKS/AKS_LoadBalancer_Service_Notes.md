# Kubernetes Service Type LoadBalancer in AKS — FULL DETAILED NOTES

This document contains **fully detailed, expanded, non‑summarized notes** for the Kubernetes Service Type LoadBalancer in Azure Kubernetes Service (AKS). This version includes all terminology, YAML/annotation explanations, network behavior, NSG updates, and step‑by‑step real execution details.

---
# 1. Introduction
A **Kubernetes Service of type LoadBalancer** exposes an application running inside a Kubernetes cluster to the **public internet** using a **cloud-provider-managed load balancer**.

In AKS (Azure Kubernetes Service), creating a Service of type LoadBalancer automatically provisions:
- An **Azure Load Balancer** (Layer 4)
- A **Public IP Address** (dynamic or static)
- Required **NSG (Network Security Group) rules**
- Optional **DNS label** on the Public IP

All provisioning and configuration occurs automatically through Kubernetes. You should **never manually modify** Azure LB or Public IP resources — changes must be made **at the Kubernetes Service level**, and AKS will propagate modifications into Azure resources.

---
# 2. How AKS Creates a Load Balancer
When you run:
```
kubectl expose deployment my-app --type=LoadBalancer --port=80
```
AKS performs the following:
1. Creates a Kubernetes LoadBalancer Service.
2. Azure Resource Provider provisions:
   - Azure Load Balancer
   - Frontend Public IP
3. Azure updates NSG rules to allow inbound traffic to the exposed port.
4. Azure automatically maintains backend pools with node IPs.

---
# 3. Important Rule — Do NOT modify Azure LB/PIP manually
Azure LB and Public IP created by a Kubernetes Service are **owned by AKS**.

If you manually change these resources from the Azure Portal, AKS may:
- Overwrite them
- Reconcile them back to the expected state
- Break the Service behavior entirely

All modifications must be done via:
- The Service YAML
- Kubernetes annotations

---
# 4. What Are Kubernetes Annotations?
Annotations are **key-value metadata** added to Kubernetes objects. Unlike labels:
- They are NOT used for selection
- NOT used for grouping
- Only used to pass metadata or configuration to controllers or cloud providers

Example structure:
```
metadata:
  annotations:
    key: "value"
```

Azure Load Balancer customizations rely heavily on Service annotations.

---
# 5. Creating a Sample Deployment and LoadBalancer Service
## Step 1 — Create a deployment
```
kubectl create deploy my-simple-website \
  --image=andreibarbu95/my-simple-website:v1
```

## Step 2 — Verify pod
```
kubectl get pods
```
Pod status: **Running**

## Step 3 — Expose deployment as LoadBalancer
```
kubectl expose deploy my-simple-website \
  --port=80 \
  --type=LoadBalancer
```

## Step 4 — Check service
```
kubectl get svc
```
External-IP will show `pending` until Azure provisions the LB.

Once done:
- The Public IP appears in Azure
- NSG inbound rule automatically created:
  - Allow 0.0.0.0/0 → Port 80

This allows ANYONE on the internet to access your Service.

---
# 6. Configuring DNS Label for the Azure Public IP Using Annotation
You **must not** modify the DNS label directly on the Azure Public IP.

Instead, apply this annotation:
```
service.beta.kubernetes.io/azure-dns-label-name: <label>
```
Example YAML update:
```
metadata:
  annotations:
    service.beta.kubernetes.io/azure-dns-label-name: "my-simple-website-test"
```

After editing:
```
kubectl edit svc my-simple-website
```
AKS updates the Public IP:
- DNS becomes:
```
my-simple-website-test.<region>.cloudapp.azure.com
```

Browser access works immediately.

Cloud Shell curl also works:
```
curl my-simple-website-test.<region>.cloudapp.azure.com
```

---
# 7. Restricting Access to Specific IP Ranges (Source IP Filtering)
Azure Load Balancer allows restricting inbound traffic using this annotation:
```
service.beta.kubernetes.io/load-balancer-source-ranges
```
This accepts a **list of CIDR ranges**.

Example goal: Allow only YOUR IP.

## Step 1 — Get your public IP
```
curl ifconfig.me
```
Assume result:
```
82.77.248.29
```
Convert to CIDR (/32):
```
82.77.248.29/32
```

## Step 2 — Edit Service
```
kubectl edit svc my-simple-website
```
Add:
```
spec:
  loadBalancerSourceRanges:
  - 82.77.248.29/32
```

## Step 3 — Result in NSG
AKS automatically updates the NSG rule:
- Source changed from `0.0.0.0/0`
- Now matches only your `/32` IP

Browser access:
- 🟢 Works from your IP
- 🔴 Fails from any other IP

Cloud Shell access:
- Fails initially

To allow Cloud Shell, add another `/32` range.

---
# 8. Adding Multiple Allowed IPs
Just extend the list:
```
spec:
  loadBalancerSourceRanges:
  - 82.77.248.29/32        # your IP
  - 20.191.224.12/32       # cloud shell IP
```
Propagation may take ~1 minute.

After propagation:
- Both IPs can access
- Others are blocked

---
# 9. Removing Restrictions (Allow Public Access Again)
To restore full internet access:
1. Edit Service:
```
kubectl edit svc my-simple-website
```
2. Remove the entire `loadBalancerSourceRanges:` section.

Azure updates the NSG:
- Restores default rule
- Source = `0.0.0.0/0`

Service becomes public again.

---
# 10. Key Takeaways
- AKS LoadBalancer Services create Azure resources **automatically**.
- Modify configuration **only in Kubernetes**, never directly in Azure.
- Use annotations for DNS, outbound rules, and source IP filtering.
- Source restriction uses `/32` when allowing a single IP.
- NSG changes always sync automatically from Service configuration.
- You can dynamically tighten or loosen access using the Service YAML.

---
# 11. Reference Diagram
```
+-----------------------------------------------------+
|                    Kubernetes Service               |
|                type: LoadBalancer                   |
|                                                     |
|  annotations:                                       |
|    azure-dns-label-name                             |
|    load-balancer-source-ranges                      |
+-----------------------------------------------------+
                | (AKS Controller Manager)
                v
+-----------------------------------------------------+
|                  Azure Cloud Resources              |
|  - Public IP (DNS label applied automatically)      |
|  - Azure Load Balancer (frontend + rules)           |
|  - NSG rules automatically updated                  |
+-----------------------------------------------------+
```

---
# End of Full Detailed Notes
