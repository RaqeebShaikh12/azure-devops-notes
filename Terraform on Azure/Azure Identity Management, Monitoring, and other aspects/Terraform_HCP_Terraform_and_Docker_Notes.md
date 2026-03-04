# Terraform, HCP Terraform & Docker — Notes

## 1) Introduction to HCP Terraform
HCP Terraform (Terraform Cloud) is a managed platform that executes Terraform runs without requiring the user to run Terraform locally. It provides:
- Remote `plan` and `apply`
- Secure state storage with versioning
- Integration with GitHub for automatic runs
- Variable and secrets management
- Role-Based Access Control (RBAC)
- Run history and audit logs

This solves local issues such as missing Terraform executable, unsafe state files, and manual execution.

---

## 2) Creating an HCP Terraform Account
Steps:
1. Sign up at HashiCorp’s Terraform Cloud portal.
2. Verify your email.
3. Create an **organization**.
4. Inside it, begin creating workspaces for your environments.

An organization can manage multiple projects and teams.

---

## 3) Creating a Workspace (Version Control Workflow)
HCP Terraform offers several workflow types:
- Version Control (GitHub, GitLab, Bitbucket, Azure DevOps)
- CLI-driven
- API-driven

Using **Version Control Workflow**, you connected GitHub by:
1. Authorizing the HashiCorp GitHub app.
2. Selecting your Terraform repository.
3. Choosing the desired branch (e.g., `dev`).
4. Creating the workspace.

Terraform Cloud:
- Reads your Terraform configuration
- Detects variables
- Prepares the workspace for remote runs

---

## 4) Running Terraform in HCP Terraform
Once your workspace is linked:
- Click **Start Plan**
- Terraform Cloud automatically performs:
  - `terraform init`
  - `terraform plan`
- You review & click **Confirm and Apply**
- Terraform Cloud deploys resources into Azure

Benefits:
- No local dependencies
- Fully logged runs
- Team visibility
- State automatically handled

---

## 5) State Management in HCP Terraform
Each workspace has:
- Its own separate state file
- State history & versioning
- Automatic locking
- Encrypted remote storage

You viewed state under the *States* tab.

---

## 6) Creating a Production Workspace
You repeated the process:
1. Created another workspace
2. Linked it to the `prod` branch
3. Ran a plan → apply

Azure now contains:
- dev resources
- prod resources

Each workspace = independent state.

---

## 7) Auto-Triggering Runs on GitHub Push
When you edited the `dev` branch in GitHub:
- Terraform Cloud detected commit
- Triggered automatic plan
- Showed diff (e.g., updated IP address tags)
- You confirmed apply
- Azure updated in real time

Then merging `dev` → `prod` triggered a new plan in the production workspace.

This enables GitOps-style automation.

---

## 8) Containers & Why They Matter
Traditional VM problems:
- Environment drift (“works on my machine”)
- Conflicts between multiple apps on same VM
- Heavy & slow to boot

Containers solve this:
- Package app + dependencies together
- Run isolated processes sharing the VM OS kernel
- Small size, fast startup
- Easily portable and reproducible

Docker is the most popular tool for managing containers.

---

## 9) Installing Docker on Linux VM
Steps followed:
1. Deploy Ubuntu 24.04 VM
2. Allow port 80
3. SSH into VM
4. Install Docker Engine via official commands

Validated with:
```
docker --version
docker ps
```
---

## 10) Running an Nginx Container on VM
Pulled nginx from Docker Hub:
```
sudo docker run -p 80:80 -d nginx
```
This:
- Downloads nginx image
- Runs it detached
- Maps container port 80 → VM port 80

Opening VM public IP displayed the nginx homepage.

---

## 11) Building Your Own Docker Image
You created a PHP application:
- `index.php`
- `lib/` folder
- Dockerfile:
```
FROM php:apache
COPY . /var/www/html
```

### Steps:
1. Copy files to VM using FileZilla (SFTP)
2. Build custom image:
```
sudo docker build -t phpapp .
```
3. Stop nginx container
```
sudo docker stop <id>
```
4. Run your custom container:
```
sudo docker run -d -p 80:80 phpapp
```

Your custom PHP site was accessible at:
```
http://<vm-public-ip>/index.php
```

---

## 12) Purpose of Building Custom Images
This sets the foundation for:
- Azure Container Registry (ACR)
- Azure Container Instances (ACI)
- Kubernetes clusters (AKS)
- Terraform-managed deployments of container workloads

You now understand:
- Pulling public images
- Building private images
- Running containers
- Mapping ports

---

## 13) Azure Container Registry & Next Steps
Following these Docker basics, you are ready to learn:
- Creating ACR with Terraform
- Pushing Docker images to ACR
- Deploying ACI or AKS using Terraform
- Configuring authentication with managed identities
- Automating container deployments

---

*End of notes.*
