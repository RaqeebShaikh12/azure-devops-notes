
# AKS Marketplace Extensions & kubectl Krew Plugins — Detailed Notes (Part 2)

## 6. Azure Marketplace Kubernetes Applications (Extensions)
Azure Marketplace contains Kubernetes apps packaged as extensions. These apps may be:
- Free
- Paid per core, per node, per month, etc.

You can deploy these from:
- Azure Portal → Azure Marketplace → Kubernetes Apps
- AKS Cluster → Extensions + Applications → Add

Examples include:
- Traefik
- Cilium
- SFTP server
- Security scanners

---

## 7. Installing an Extension (Traefik Example)
When installing Traefik from Marketplace:

### AKS automatically deploys system operators:
- **Billing Operator**
- **Extension Operator**
- **Extension Agent**

These components manage billing, upgrades, and lifecycle.

### Application-level resources deployed:
- Traefik controller pods
- Traefik ConfigMaps
- Traefik Service (LoadBalancer)

You verified using:
```
kubectl get pods -A
kubectl get svc -A
```

---

## 8. Exposing an Application Using Traefik
You deployed nginx:
```
kubectl create deploy nginx --image=nginx
kubectl expose deploy nginx --port=80
```

You verified that Traefik ingress class exists:
```
kubectl get ingressclass
```

Then created an ingress resource pointing to Traefik:
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  annotations:
    kubernetes.io/ingress.class: traefik-extension
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx
            port:
              number: 80
```

After applying the ingress, you accessed nginx through Traefik’s public LoadBalancer IP.

---

## 9. Removing an Extension
From Azure Portal:
```
AKS → Extensions + Applications → Select Extension → Uninstall
```
This removes:
- Traefik workloads
- Operators
- LoadBalancer service

---

## 10. kubectl Plugins & Krew Manager
Krew is a **plugin manager** for kubectl.
It simplifies discovering, installing, updating, and removing plugins.

### View krew commands:
```
kubectl krew -h
```

### Search plugins:
```
kubectl krew search
```

You saw many plugins like:
- grep
- ctx (context switcher)
- ns (namespace switcher)
- neat
- view-utilization
- who-can

---

## 11. Installing a Plugin (grep Example)
Install:
```
kubectl krew install grep
```
Use it:
```
kubectl grep pod dns -A
```
This is easier than:
```
kubectl get pod -A | grep dns
```

### Uninstall plugin:
```
kubectl krew uninstall grep
```

### Verify plugin list:
```
kubectl krew list
```

---

## 12. Summary
You now understand:
- What kubeconfig is and how it works
- How to switch between clusters
- How Marketplace extensions work
- How Traefik was deployed as an extension
- How to expose workloads using an ingress
- How kubectl plugins extend functionality
- How Krew makes plugin management easy

These skills are essential for managing multiple AKS clusters and extending Kubernetes functionality efficiently.

---
