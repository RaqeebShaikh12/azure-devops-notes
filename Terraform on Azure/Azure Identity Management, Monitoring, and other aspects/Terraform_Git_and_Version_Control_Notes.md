# Terraform + Git for Multi-Environment Management — Notes

## 1) Why Use Git for Terraform Code?
Terraform is infrastructure-as-code, so it benefits from proper version control:
- Track all changes
- Roll back safely
- Collaborate using branches
- Maintain dev/prod parity
- Review changes before deployment

Git enables professional, safe, traceable Terraform workflows.

---

## 2) Installing Git
Git must be installed locally. On Windows:
- Download from git-scm.com
- Install using default options
- Accessible via VS Code, CMD, or PowerShell

---

## 3) Initializing a Local Git Repository
Inside your Terraform folder:

### .gitignore example
```
terraform.exe
.terraform/
*.tfstate
*.tfstate.backup
*.plan
.terraform.lock.hcl
```

### Initialize repo
```
git init
```

### Stage & commit
```
git add .
git commit -m "Initial commit"
```

Git now tracks all Terraform source files.

---

## 4) Publishing Code to GitHub
1. Create a GitHub repo
2. Add remote origin:
```
git remote add origin <repo-url>
```
3. Push code:
```
git push -u origin dev
```

Your Terraform code and version history now live in GitHub.

---

## 5) Making Code Changes Locally
Example change: adding a data disk in `modules/compute/main.tf`.
Git automatically detects modified files.

Commit changes:
```
git add .
git commit -m "Added data disk"
git push origin dev
```

GitHub now shows updated code + commit history.

---

## 6) Working With Branches (Feature → Dev → Prod)
Typical branching structure:
- **dev** branch — active development
- **prod** branch — stable production-ready code
- **feature/*** branches — short-lived, per change request

### Create a feature branch:
```
git checkout -b feature-123
```

After making changes locally:
```
git commit -m "VNet tag update"
git push origin feature-123
```

### Pull Request (Feature → Dev)
- Compare feature branch with dev branch
- Review changes
- Merge without conflicts

Dev branch now includes the new update.

---

## 7) IT Admin Deployment Workflow (Dev)
IT admin downloads code from dev branch:
1. Download ZIP from GitHub → Extract
2. Place terraform.exe in folder
3. Run:
```
terraform init
terraform plan
terraform apply
```

### Problem:
Without an existing state file → Terraform plans to recreate **all** resources.

This demonstrates why **environment-specific state files** are mandatory.

---

## 8) Promoting Dev → Prod
Once Dev branch is validated:
1. Create PR: dev → prod
2. Review
3. Merge

Production branch now matches development.

---

## 9) Production Deployment (IT Admin)
Admin downloads code from prod branch.
Updates `terraform.tfvars` with prod settings.
Runs Terraform.

### Again: State problem appears if state is missing.
Terraform wants to destroy dev resources and create prod ones.

Solution: **remote, isolated state files.**

---

## 10) Cause of All Deployment Issues: Shared State
Terraform stores resource metadata in `terraform.tfstate`.
If dev & prod share the same file:
- Terraform thinks resources changed
- Wants to replace or delete them
- Environments collide

Each environment MUST have a separate state file.

---

## 11) Solution — Remote State Backend (Azure Storage)
Create a storage account manually:
- Resource group: `TerraformRG`
- Storage account: e.g., `tfstateglobal123`
- Containers:
  - `terraformdev`
  - `terraformprod`

### Configure backend in Terraform:
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "TerraformRG"
    storage_account_name = "tfstateglobal123"
    container_name       = "terraformprod"  # or terraformdev
    key                  = "terraform.tfstate"
  }
}
```

### Benefits of remote state:
- Separate state files per environment
- Safe for team collaboration
- State available anywhere
- Automatic locking

---

## 12) Deployment Flow After Backend Setup
### Dev environment:
```
terraform init
terraform apply
```
State stored inside: `terraformdev`

### Prod environment:
```
terraform init
terraform apply
```
State stored inside: `terraformprod`

Both environments are fully isolated.

---

## 13) Alternative Strategy — Folder-Based Environments
Instead of branches:
```
environments/
   dev/
     main.tf
     terraform.tfvars
   prod/
     main.tf
     terraform.tfvars
modules/
```

### Pros:
- Clear separation
- Easy navigation

### Cons:
- Code duplication risk
- Harder to maintain large infrastructure

Teams use this depending on comfort and project complexity.

---

## 14) Diagram — Git + Terraform + Remote State
```
                     GitHub Repository
               +------------------------------+
               |            main repo          |
               +------------------------------+
                      /                              dev branch            prod branch
                   |                      |
           terraformdev state     terraformprod state
            (Azure Storage)        (Azure Storage)
                   |                      |
        terraform apply (dev)   terraform apply (prod)
```

---

## Summary
Using Git + Terraform enables:
- Safe, controlled infrastructure deployments
- Clear dev → prod workflow
- Change tracking & code reviews
- Isolation of environments via remote state

This is a production-grade approach for modern cloud teams.

---

*End of notes.*
