# AKS Connectivity Agent & Kube-Proxy – Detailed Notes (Part 2)

## 4. Connectivity Agent (Critical for Exec/Logs/Port-Forward)
The Connectivity Agent forms a tunnel between the API server and Kubelet.

### 4.1 Why It Matters (Layman Terms)
If this component breaks, Kubernetes cannot talk to your pods.

### 4.2 Features That Depend on Connectivity Agent
- `kubectl logs`
- `kubectl exec`
- `kubectl port-forward`
- Admission webhook communication

### 4.3 Your Demo Summary
You:
1. Cordoned nodes
2. Deleted connectivity-agent pods
3. They remained pending → No scheduling
4. Exec/logs/port-forward failed
5. Uncordoned nodes → Agent recreated
6. Everything worked again

---

## 5. Kube-Proxy – Kubernetes Internal Traffic Router
Kube-proxy manages `iptables` rules that route traffic from Services → Pods.

### 5.1 Why Kube-Proxy Is Needed
Pods are ephemeral. IPs change frequently. Services provide a stable virtual IP. Kube-proxy ensures traffic reaches the correct pods.

### 5.2 Your Demo Summary
1. Followed kube-proxy logs
2. Created an nginx deployment
3. Exposed it via a ClusterIP service
4. Observed kube-proxy creating NAT rules
5. Verified service chains in iptables
6. Scaled deployment and saw probability changes

### 5.3 Probability Logic
- 1 pod → 100%
- 2 pods → 50/50
- 3 pods → 33/33/34
- 4 pods → 25/25/25/25

### 5.4 Commands Used
```
kubectl logs -n kube-system -l k8s-app=kube-proxy -f
iptables -t nat -L KUBE-SERVICES -n | grep nginx
kubectl get endpoints nginx-svc
kubectl scale deploy nginx --replicas=3
```

---

## 6. Component Summary (Layman Friendly)
- **CoreDNS** → Internal DNS server using plugins
- **DNS Autoscaler** → Auto-scales CoreDNS pods
- **CSI Drivers** → Azure Disk/File/Blob storage integration
- **Connectivity Agent** → Enables logs/exec/port-forward
- **Kube-Proxy** → Forwards traffic from Services → Pods using iptables

---
