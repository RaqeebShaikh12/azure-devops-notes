# Comprehensive Containers and Fundamentals — Notes

## 1. Evolution: Physical Servers → VMs → Containers
Before virtualization, companies ran **one application per physical server**, causing:
- Poor hardware utilization
- High operational costs
- Compatibility issues between applications

### Virtual Machines (VMs)
VMs use a **hypervisor** (software that creates and manages virtual machines) to run multiple VMs on one server. Each VM has:
- Its own OS (guest OS)
- Its own CPU, RAM, storage allocation
- Full process isolation

### VM Limitations
- Slow startup (minutes)
- Heavy resource consumption
- Large images (GBs)
- OS licensing costs per VM
- Conflicts when installing multiple applications inside one VM

---

## 2. Containers: Lightweight Application Packaging
A **container** is a package containing:
- Application code
- Libraries
- Dependencies
- Runtime
- Environment variables

Containers:
- Share the host OS **kernel**
- Are extremely lightweight (MBs)
- Start in seconds
- Are portable across machines

### What Is the Kernel?
The **kernel** is the core part of an operating system that manages:
- CPU
- Memory
- Networking
- Hardware communication

**Analogy:** The kernel is the *brain* of the OS.

---

## 3. How Containers Achieve Isolation
Containers rely on two core Linux technologies:

### Namespaces (Provide Isolation)
Namespaces ensure each container has its own:
- Process list (PID namespace)
- Network stack (Network namespace)
- Filesystem view (Mount namespace)
- Users (User namespace)
- Hostname (UTS namespace)

**Analogy:** Each container is a separate room in the same house.

### Control Groups (cgroups)
**cgroups** control how much CPU, memory, and IO a container can use.

**Analogy:** Electrical breakers controlling power usage.

---

## 4. Containers vs Virtual Machines
| Feature | VM | Container |
|--------|----|-----------|
| Size | GBs | MBs |
| Startup Time | Minutes | Seconds |
| OS | Full OS per VM | Shared kernel |
| Isolation | Strong | Medium |
| Resource Usage | Heavy | Lightweight |
| Portability | Medium | Very high |

### Security Note
Containers isolate applications well, but they share the same kernel. Kernel-level vulnerabilities can impact all containers.

For strict isolation, VMs may be preferable.

---

## 5. Microservices Architecture
### Monolithic Applications
- All code and features in one large application
- Hard to scale
- Hard to update
- Downtime required for small changes

### Microservices
Break a large application into small, independent services.

**Why Containers Fit Microservices:**
- Independent deployment
- No shared dependency conflicts
- Easy scaling
- Clear separation of responsibilities

Example (E-commerce platform):
- Auth service
- Catalog service
- Cart service
- Order service

---

## 6. Docker: The Popular Container Engine
Docker provides:
- Container runtime
- CLI for container management
- Image building capability
- Networking and storage for containers

### What Is a Dockerfile?
A text file describing how to build a Docker image.
Example:
```
FROM ubuntu
RUN apt-get install curl
COPY index.html /var/www/html/
CMD ["sleep", "infinity"]
```

### Docker Image vs Docker Container
- **Image** → Blueprint (recipe)
- **Container** → Running instance (actual dish)

---

## 7. Docker Hub — Public Image Registry
A cloud repository for storing and distributing Docker images.
Useful for:
- Sharing images with teams
- Deploying to Kubernetes
- Public distribution

---

## 8. Example: Simple Website Container
You:
1. Created a basic HTML file
2. Used `nginx:alpine` as base
3. Built image with Dockerfile
4. Tagged and pushed it to Docker Hub
5. Ran container locally:
```
docker run -p 80:80 <image>
```
Checked via:
```
http://localhost
```
The site displayed successfully.

---

## 9. Example: Troubleshooting Application Container
A Bash script continuously:
- Sends HTTP requests
- Measures response time
- Prints HTTP status code
- Runs in a loop

### Dockerfile Used:
```
FROM ubuntu
RUN apt-get update && apt-get install -y curl
WORKDIR /app
COPY script.sh /app
CMD ["/app/script.sh"]
```

### Uses
- Detecting intermittent web downtime
- Monitoring latency patterns
- Debugging performance problems

---

## 10. Why We Need a Container Orchestrator
Docker alone cannot:
- Auto-restart broken containers
- Distribute traffic
- Auto-scale applications
- Self-heal failed nodes
- Manage multi-node clusters
- Perform zero-downtime updates
- Handle secrets/config management

### Kubernetes solves all these challenges.
Kubernetes automates deploying, scaling, healing, and managing containers.

This leads directly into Azure Kubernetes Service (AKS).

---

*End of notes.*
