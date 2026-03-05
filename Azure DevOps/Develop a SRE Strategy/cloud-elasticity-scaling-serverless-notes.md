
# Cloud Elasticity, Scaling, Load Balancing & Serverless Computing – Complete Notes

This file contains clear, structured, layman-friendly notes covering elasticity, scaling strategies, autoscaling, load balancing, serverless computing, and relevant cloud concepts.

---

## 1. Introduction to Elasticity
Elasticity is a key advantage of cloud computing. It means cloud systems can **automatically expand** when workloads increase and **shrink** when demand decreases.

### Why Elasticity Matters
- Ensures performance during high traffic
- Reduces cost during low traffic
- Supports unpredictable workloads (viral events, big sales, sports matches)
- Enables better user experience and operational efficiency

Example: Pizza delivery sites experience huge spikes during game nights and holidays. Elasticity ensures they stay responsive.

---

## 2. Compute Load Patterns
Cloud workloads rarely stay constant.

### ✔ Consistent Growth
Steady increase in traffic over time.
- Easy to plan for
- Cloud adapts more quickly than physical servers

### ✔ Constantly Fluctuating Loads
Demand changes unpredictably throughout the day.
- Cannot keep max servers running continuously
- Autoscaling is essential

### ✔ Cyclical Loads
Daily, weekly, monthly patterns.
Example: Business apps peak during work hours.

### ✔ Unpredictable Bursts
Sudden spikes due to:
- Viral content
- Unexpected demand
- Breaking news

Elasticity is crucial for handling such bursts.

---

## 3. Scaling Compute Resources
Scaling adjusts resources to match demand.

### ✔ Horizontal Scaling (Scale Out / Scale In)
Add or remove **more instances**.
- Fine-grained scaling
- High availability
- Ideal for unpredictable loads

Containers scale faster than VMs → better elasticity.

### ✔ Vertical Scaling (Scale Up / Scale Down)
Increase or decrease the **power of one instance** (CPU, RAM).

Drawbacks:
- Requires brief downtime
- Limited flexibility
- Single point of failure

Most cloud systems prefer **horizontal scaling**.

---

## 4. Scaling the Server Tier
### ✔ Choosing the Right VM Type
Cloud providers offer:
- Compute-optimized VMs
- Memory-optimized VMs
- Network-optimized VMs

Choosing correct VM type improves performance and reduces cost.

### ✔ Stateless vs Stateful Architecture
**Stateless services** scale easily (no server stores user data locally).

**Stateful services** require:
- Sticky sessions
- Distributed caches
- External storage

Stateless is preferred for elasticity.

---

## 5. Scaling the Data Tier
Challenges:
- Disk I/O limits
- Network latency
- Data consistency

Strategies:
### ✔ Replication
Multiple database copies improve read performance & availability.

### ✔ Sharding (Partitioning)
Split data across multiple servers.
- Improves scale
- Reduces load per server

### ✔ CAP Theorem
Distributed databases can fully provide only **two** of the following:
- **C**onsistency
- **A**vailability
- **P**artition tolerance

---

## 6. Autoscaling
Manually scaling is reactive and error-prone. Autoscaling adjusts resources automatically.

Two main types:

### ✔ Time-Based Autoscaling
Useful for predictable patterns.
Examples:
- Scale up at 9am
- Scale down at night

Cloud example: Azure App Service scheduled autoscaling.

### ✔ Metrics-Based Autoscaling
Triggered using real-time metrics like:
- CPU usage
- Memory usage
- Latency
- Request queue length
- Throughput

AWS uses CloudWatch → triggers autoscaling.
Azure uses autoscale rules in VMSS / App Service.
Google uses Compute Engine autoscaler.

### ✔ Predictive Autoscaling
Uses machine learning to predict traffic spikes.
- AWS Predictive Scaling
- Azure uses ML to predict VM failures

---

## 7. Load Balancing
Scaling out is useless unless traffic is distributed evenly.

Load balancers:
- Distribute requests
- Improve reliability
- Detect failed servers
- Prevent overload

### ✔ Why Load Balancing Matters
- Parallel processing improves throughput
- Reduces latency
- Provides fault tolerance

---

## 8. Load Balancing Methods
### ✔ DNS Load Balancing
Uses multiple IPs. Outdated, slow for failover.

### ✔ Modern Load Balancers
Two modes:
- **Proxy Mode** – load balancer handles both request & response
- **TCP Handoff** – server communicates directly with client after handoff

### ✔ Algorithms
#### Round Robin
Equal distribution; simple.
Used by AWS ELB.

#### Hash-Based
Uses combinations of IP/port to route.
Used by Azure Load Balancer.

#### Least Connections / Least CPU
Sends traffic to least-loaded server.

#### Execution-Time-Based
Predicts fastest server.

### ✔ Additional Load Balancer Features
- SSL offloading
- Caching
- TCP buffering
- Traffic shaping

---

## 9. Serverless Computing
Serverless abstracts away all infrastructure.
You focus only on code or workflow.

### ✔ Types of Serverless
1. **Serverless Functions** (Azure Functions, AWS Lambda, Google Cloud Functions)
2. **Serverless Workflows** (Azure Logic Apps, AWS Step Functions)
3. **Serverless Databases** (Azure SQL Serverless, Aurora Serverless, Firestore)

### ✔ Benefits
- Consumption-based pricing → pay only when code runs
- Automatic scaling
- Zero maintenance

### ✔ Drawbacks
- Cold start delays
- Timeout limits
- Stateless nature
- Vendor lock-in

---

## 10. Serverless Functions
Support multiple languages such as:
C#, Java, JavaScript, Python, Go, PowerShell, etc.

### ✔ Trigger Types
- Timers
- File uploads
- HTTP requests
- Queue messages

### ✔ Use Cases
- Nightly backups
- Billing jobs
- Data processing
- Connecting cloud services

---

## 11. Serverless Workflows
Example: Azure Logic Apps
- 100+ built-in connectors
- Trigger-based automation
- Can call Azure Functions for custom logic

Example: AWS Step Functions
- Visual workflows
- Branching, parallel execution
- Integration with Lambda & ECS

---

## 12. Serverless Databases
Examples:
- Azure SQL Serverless
- AWS Aurora Serverless
- Google Firestore

Benefits:
- Autoscaling
- Pay for actual usage
- Ideal for irregular workloads

---

## Summary
Key concepts learned:
- Cloud workloads fluctuate → elasticity required
- Scaling: horizontal (preferred) and vertical
- Autoscaling reduces cost and maintains performance
- Load balancing ensures even traffic distribution
- Serverless computing reduces admin overhead
- Serverless functions and workflows simplify cloud automation
- Serverless databases scale automatically

Cloud elasticity ensures cost-efficiency, high performance, and seamless user experiences.

---

**End of Notes**
