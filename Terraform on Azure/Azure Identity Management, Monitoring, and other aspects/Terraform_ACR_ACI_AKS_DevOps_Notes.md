# Terraform, ACR, ACI, AKS & Azure DevOps CI/CD — Notes

## 1) Azure Container Registry (ACR)
ACR is Azure’s private Docker registry used to store & manage container images.

### Why ACR?
- Central place to store Docker images
- Secure access with RBAC
- Enables teams & Azure services (ACI, AKS) to pull images
- Supports webhooks, geo‑replication & private networks

### Steps Performed
1. Created ACR manually in Azure Portal
2. Enabled Admin User (simple username/password access)
3. Verified empty repository list
4. Prepared to push custom Docker image

---

## 2) Pushing Docker Image from VM to ACR
### Commands Used
**Login:**
```
sudo docker login <acr-login-server> -u <username> -p <password>
```

**Tag image:**
```
sudo docker tag phpapp <acr-login-server>/phpapp
```

**Push image:**
```
sudo docker push <acr-login-server>/phpapp
```

Once pushed, the ACR repository displays:
- Repository: `phpapp`
- Tag: `latest`

---

## 3) Azure Container Instances (ACI)
ACI allows running containers **without VMs**, fully managed by Azure.

### What You Did:
- Selected ACR as image source
- Chose PHP application image
- Exposed port 80
- Deployed container
- Accessed using ACI’s public IP:
```
http://<aci-ip>/index.php
```
App worked successfully.

---

## 4) Deploying ACI using Terraform
Using resource:
```
azurerm_container_group
```

### Key Components
- Public IP
- Linux OS
- One container using ACR image
- CPU & memory settings
- Port 80 exposed

### Secure ACR Access via Data Block
```
data "azurerm_container_registry" "acr" {
  name                = "myregistry"
  resource_group_name = "DockerGRP"
}
```

This avoids hardcoding credentials.

### Execution
```
terraform init
terraform plan
terraform apply
```

Container group created → app accessible at public IP.

---

## 5) Deploying AKS (Kubernetes) Using Terraform
AKS is Azure’s container orchestration platform.

### Authentication — Best Practice
Use environment variables:
```
export ARM_CLIENT_ID=...
export ARM_CLIENT_SECRET=...
export ARM_TENANT_ID=...
export ARM_SUBSCRIPTION_ID=...
```
Avoids storing secrets in Terraform files.

### Terraform Resource
```
azurerm_kubernetes_cluster
```
Creates:
- Cluster
- Default Linux node pool
- Service principal / managed identity

### Allow AKS to Pull Images from ACR
Using:
```
azurerm_role_assignment
```
Role: **AcrPull**
Principal: kubelet identity of AKS
Scope: ACR

### Deploying App to AKS
1. Applied deployment YAML (image: `<acr>/phpapp:latest`)
2. Applied LoadBalancer YAML
3. Received external IP
4. Accessed app:
```
http://<external-ip>/index.php
```
Works successfully.

---

## 6) Continuous Integration (CI) Concepts
CI ensures:
- Every commit triggers build
- Automated tests run
- Early detection of broken changes
- Small, frequent integrations

Azure DevOps tools used:
- Azure Repos (source control)
- Azure Pipelines (CI/CD engine)
- Service Connections

---

## 7) DotNet Application + Terraform Setup
Steps followed:
1. Installed .NET 8 SDK
2. Created Razor Web App
3. Verified local execution
4. Added Terraform infra folder
5. Created resources:
   - Resource Group
   - App Service Plan
   - Web App

Removed build artifacts (`bin/`, `obj/`) before committing.

---

## 8) Uploading Code to Azure Repos
```
git init
git add .
git commit -m "Initial commit"
git checkout -b dev
git remote add origin <Azure-Repos-URL>
git push -u origin dev
```

Repo now contains:
- Application code
- Infrastructure code

---

## 9) Azure Pipelines — Build Pipeline (CI)
Pipeline builds application & produces artifacts.

### Tasks:
- Checkout source
- Dotnet build
- Dotnet publish
- Publish app artifact
- Publish Terraform artifact

Build output:
- ZIP file for web app
- Terraform infra folder (zipped)

---

## 10) Azure Pipelines — Release Pipeline (CD)
Stage: **Deploy to Dev**

### Tasks in sequence:
1. Install Terraform
2. Terraform Init (using Azure Storage backend)
3. Terraform Plan
4. Terraform Apply (creates Web App infra)
5. Deploy Web App artifact to Azure Web App

### Infra State Storage
- Storage Account created
- Container holds terraform.tfstate

### App Deployment
Uses the artifact ZIP → Deploys to Azure App Service.

App accessible via:
```
https://<webapp>.azurewebsites.net/
```

---

## 11) Complete CI/CD Flow
### Developer:
- Pushes commit to dev branch

### CI Pipeline:
- Builds application
- Publishes artifacts

### CD Pipeline:
- Provisions infrastructure using Terraform
- Deploys web app
- Deploys application

### Outcome:
Production-grade automation for:
- App deployment
- Terraform infra deployments
- State management
- Git-based promotion workflow

---

*End of notes.*
