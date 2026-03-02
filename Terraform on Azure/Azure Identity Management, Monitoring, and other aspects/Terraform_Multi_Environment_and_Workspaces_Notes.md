# Terraform Multi-Environment and Workspaces — Notes

## 1) Why Multi‑Environment Infrastructure Matters
Organizations typically maintain multiple environments such as **dev**, **QA**, **staging**, and **production**. These environments require:
- Identical infrastructure patterns
- Isolated deployments
- Independent state tracking
- Controlled promotion from dev → prod

Terraform enables consistent provisioning across all environments while avoiding code duplication.

---

## 2) Initial Module-Based Architecture
Your base infrastructure used Terraform modules:
- **network module** → VNet, Subnets, NICs
- **compute module** → VMs

Dependencies added:
```hcl
depends_on = [module.network]
```
And subnets explicitly depend on the VNet, preventing timing issues.

Before multi-env implementation, the full codebase was tested successfully.

---

## 3) Strategy #1 — Multiple .tfvars Files (Dev vs Prod)
You created:
- `dev.tfvars`
- `prod.tfvars`

Running:
```bash
terraform apply -var-file="dev.tfvars"
```
works correctly.

### ⚠️ Problem: Shared State File
When switching to prod:
- Terraform wants to **delete dev resources**
- And create prod resources

Because both runs share **one state file**, Terraform thinks the entire environment has drifted.

**Conclusion:** Multiple tfvars files do NOT safely support multiple environments.

---

## 4) Strategy #2 — Terraform Workspaces
Workspaces offer separate state files while using the same code.

### Commands Used
```bash
terraform workspace new dev	erraform workspace new prod
terrafrom workspace list
```

Terraform creates isolated state paths:
```
terraform.tfstate.d/
  dev/
  prod/
```

### Benefit
Each workspace maintains **its own state**, so applying prod does NOT overwrite dev.

---

## 5) Using terraform.workspace for Dynamic Naming
Example:
```hcl
resource_group_name = "${terraform.workspace}-grp"
```

Results:
- dev workspace → `dev-grp`
- prod workspace → `prod-grp`

This pattern is applied across modules.

---

## 6) Improving the Environment Variable Structure
A map was introduced in `variables.tf`:
```hcl
environment = {
  dev = {
    vnet_address_space = ["10.0.0.0/16"]
    subnets = {...}
  }

  prod = {
    vnet_address_space = ["10.1.0.0/16"]
    subnets = {...}
  }
}
```

### Accessing values dynamically:
```hcl
var.environment[terraform.workspace]
```

This ensures the correct environment block is used depending on workspace.

---

## 7) Updating locals.tf for Workspaces
### Virtual Network:
```hcl
local.vnet_details = [{
  name          = "${terraform.workspace}-network"
  address_space = var.environment[terraform.workspace].vnet_address_space
}]
```

### Subnets:
```hcl
local.subnet_details = flatten([
  for key, subnet in var.environment[terraform.workspace].subnets : {
    subnet_key    = key
    address_pref  = subnet.address_prefix
    vnet_name     = "${terraform.workspace}-network"
  }
])
```

### NICs & VM details were updated similarly.

---

## 8) Deploying with Workspaces
### Dev environment:
```bash
terraform workspace select dev
terraform apply
```
Creates:
- dev-grp
- dev-network
- All dev subnets, NICs, VMs

---

### Prod environment:
```bash
terraform workspace select prod
terraform apply
```
Creates:
- prod-grp
- prod-network
- All prod resources

**No deletions occur**, thanks to separate state directories.

---

## 9) Safely Destroying Environments
### Destroy prod:
```bash
terraform workspace select prod
terraform destroy
```

### Destroy dev:
```bash
terraform workspace select dev
terraform destroy
```

### Remove workspaces:
```bash
terraform workspace select default
terraform workspace delete prod
terraform workspace delete dev
```

---

## 10) Diagram — Multi‑Workspace Flow
```
                 +------------------------+
                 |    Terraform Code      |
                 +------------------------+
                              |
          +-------------------+-------------------+
          |                                       |
   Workspace: dev                         Workspace: prod
          |                                       |
   State: terraform.tfstate.d/dev         State: terraform.tfstate.d/prod
          |                                       |
   +------------------------+           +-------------------------+
   | Dev Resource Group     |           | Prod Resource Group     |
   | Dev Network & VMs      |           | Prod Network & VMs      |
   +------------------------+           +-------------------------+
```

---

## Summary
Terraform Workspaces solve the multi‑environment challenge by:
- Providing **isolated state**
- Eliminating accidental resource deletions
- Enabling a **single shared codebase**
- Offering dynamic config selection using `terraform.workspace`

This is the correct, scalable approach for managing dev/prod deployments.

---

*End of notes.*
