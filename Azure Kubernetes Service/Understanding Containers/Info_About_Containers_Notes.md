# Info About Containers — Notes

## 1. Evolution: Physical Servers → VMs → Containers
Originally, companies ran **one application per physical server** due to OS incompatibility issues. This caused:
- Poor resource utilization
- High operational cost

### Virtual Machines (VMs)
VMs improved this. They use a **hypervisor** (software that creates VMs) to run multiple virtual machines on one physical server. Each VM has:
- Its own operating system (guest OS)
- Allocated CPU, RAM, and storage

**But VMs still have drawbacks:**
- Slow startup (minutes)
- Heavy resource usage
- Large size (GBs)
- OS license cost per VM
- Dependency conflicts when running many apps

---

## 2. Containers: What They Are & Why They Matter
A **container** is a lightweight package that contains everything needed to run an application:
- Code
- Libraries
- Dependencies
- Runtime
- Configuration

### How Are Containers Different from VMs?
- Containers **share the host OS kernel**, unlike VMs which each have their own kernel.
- Much smaller (MBs instead of GBs)
- Start in seconds
- Easily portable across environments

### What Is the Kernel?
The **kernel** is the core part of an operating system that controls:
- CPU usage
- Memory management
- Networking
- Hardware access

Think of it like the **brain** of the OS.

---

## 3. How Containers Achieve Isolation
Containers isolate applications using two main Linux features:

### Namespaces
Provide *logical isolation* so each container gets:
- Its own process IDs (PID namespace)
- Its own network stack (Network namespace)
- Its own filesystem view (Mount namespace)
- Its own users (User namespace)
- Its own hostname (UTS namespace)

**Analogy:** separate rooms in the same house.

### Control Groups (cgroups)
Limit how much CPU, memory, and IO a container can use.

**Analogy:** electrical breakers preventing one appliance from using all power.

---

## 4. VMs vs Containers Comparison
| Feature | Virtual Machines | Containers |
|--------|------------------|------------|
| Size | GBs | MBs |
| Startup Time | Minutes | Seconds |
| Isolation | Strong (separate kernel) | Good (shared kernel) |
| Resource Usage | Heavy | Lightweight |
| Portability | Medium | Very High |

**Note:** Containers isolate applications well, but since they share the kernel, kernel-level security issues may impact all containers.

---

## 5. Microservices Architecture & Containers
### Monolithic Applications
- All features in one codebase
- Hard to scale
- Redeploy entire app for small changes

### Microservices
Break the application into small, independently deployable services.

**Why containers fit microservices perfectly:**
- Each service can run in its own container
- No dependency conflicts
- Fast scaling
- Independent deployment

---

## 6. Docker: The Container Engine
Docker is software that:
- Builds containers
- Runs containers
- Manages container lifecycle
- Uses Dockerfile to define images

### Dockerfile
A script with instructions to build a Docker image, e.g.:
```
FROM ubuntu
RUN apt-get install curl
COPY index.html /var/www/html/
CMD ["sleep", "infinity"]
```

### Docker Image
A template containing the application & dependencies.

### Docker Container
A running instance of the image.

**Analogy:**
- Image = Recipe
- Container = Cooked dish

---

## 7. Docker Hub
A public registry to store and share Docker images.
Used when deploying to Kubernetes or sharing images across teams.

---

## 8. Example: Simple Website Container
You built a website using:
- `nginx:alpine` as base
- Custom HTML file
- Dockerfile with COPY & EXPOSE

Then you:
- Built the image
- Tagged it
- Pushed it to Docker Hub
- Ran the container locally using:
```
docker run -p 80:80 <image-name>
```
And accessed via `http://localhost`.

---

## 9. Example: Troubleshooting Application Container
Created a Bash script to:
- Measure HTTP response time
- Print status code
- Run in loop for monitoring

Dockerfile:
- Based on Ubuntu
- Installs `curl`
- Copies script
- Runs script on start

Useful for:
- Detecting latency issues
- Website performance monitoring
- Pattern-based troubleshooting

---

## 10. Need for a Container Orchestrator
Docker alone cannot handle:
- Auto-scaling
- Auto-restarts
- Load balancing
- Rolling updates
- Multi-node deployments
- Self-healing
- Service discovery

### Kubernetes solves all of these.

This leads to **Azure Kubernetes Service (AKS)** for managing containers at scale.

---

*End of notes.*
