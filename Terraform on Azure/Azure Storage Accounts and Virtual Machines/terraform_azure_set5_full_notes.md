
# Terraform on Azure – Detailed Notes (Sections 52–60)

## 52. Introduction to Input Variables in Terraform
So far, you’ve used:

- Hardcoded values
- Local variables (locals) for reuse

Now you are learning **input variables**, which allow users to pass values dynamically when running Terraform.
This enables:

- Reusability
- Parameterized deployments
- Cleaner configurations
- Environment‑specific overrides

### What Are Input Variables?
Input variables let you **provide values at plan/apply time** instead of hardcoding them.

**Example variable definition:**
```hcl
variable "vm_name" {
  type        = string
  description = "Name of the virtual machine"
}
```

**Usage in resources:**
```hcl
name = var.vm_name
```

✔ **Behaviour During `terraform plan`**
When Terraform sees variables with no default values, it asks:
```
var.vm_name
  Name of the virtual machine
  Enter a value:
```

You entered:
```
webvm01
```

Terraform then used that value in the VM resource.

---

## 53. Fixing the VM Agent Update Drift Issue
While testing the VM variable, the plan showed:
```
1 to change
```
Because of a VM property:
```
vm_agent_platform_updates_enabled
```
Azure’s default vs Terraform’s assumed default didn’t match.
**Solution:** Explicitly set the property in the VM configuration so Terraform stops trying to correct it repeatedly.

---

## 54. Passing Input Variables Using a `.tfvars` File
As deployments grow, Terraform prompting for values becomes inefficient.
The solution:
Use **terraform.tfvars** to automatically load variable values.

### Creating the Input Variable File
You added:
```
terraform.tfvars
```

**Example:**
```hcl
vm_name     = "webvm01"
admin_user  = "appadmin"
```

Terraform automatically loads this file **without prompting**.
✔ This makes deployments repeatable and automated.

---

## 55. Adding More Input Variables
You added additional variables:

**VM Size**
```hcl
variable "vm_size" {
  type        = string
  description = "Size of the virtual machine"
  default     = "Standard_B2s"
}
```
Since it has a default → Terraform won’t prompt unless overridden.

**Admin Password**
```hcl
variable "admin_password" {
  type        = string
  description = "Admin password for the VM"
}
```
Terraform prompted:
```
var.admin_password
Enter a value:
```

But… the password was visible in terminal.

---

## 56. Masking Sensitive Variables
To hide sensitive values in the plan output, you used:
```hcl
variable "admin_password" {
  type        = string
  description = "Admin password"
  sensitive   = true
}
```

Now:

- Terraform asks for the password
- It hides input in the plan and logs

✔ Best practice for credentials.

---

## 57. Terraform Validate Command
Before running a plan, you can check the configuration using:
```
terraform validate
```

It checks:

- Syntax
- Structure
- Internal consistency

Useful before running plan/apply.

> Note: The `terraform plan` command **automatically includes validation**, but running `validate` manually helps during development.

---

## 58. Creating & Attaching a Data Disk
Azure VMs can have:

- OS Disk (automatic)
- **Data Disks** (manual)

You learned to provision Data Disks using two blocks:

### A. Create the Managed Data Disk
```hcl
resource "azurerm_managed_disk" "web_data_disk" {
  name                 = "web-data-disk01"
  location             = local.resource_location
  resource_group_name  = azurerm_resource_group.appgrp.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 4
}
```

### B. Attach Disk to VM
```hcl
resource "azurerm_virtual_machine_data_disk_attachment" "attach_disk" {
  managed_disk_id    = azurerm_managed_disk.web_data_disk.id
  virtual_machine_id = azurerm_windows_virtual_machine.webvm01.id
  lun                = 0
}
```

After apply → VM shows the additional data disk.

---

## 59. Azure Cost Management & Importance of Destroying Resources
You reviewed Azure cost best practices:

✔ **Destroy resources when done**
```
terraform destroy
```

Since VM hourly cost is low, your usage was within budget — but destroying is still important to avoid long‑term cost.

✔ **Azure Budgets for tracking cost**
Azure Portal → Cost Management → Budgets

- Set budget (e.g., $30 / month)
- Set alert threshold (e.g., 50%)
- Azure emails when triggered

This helps avoid unexpected charges.

---

## 60. Clean Slate for Next Section
You successfully performed:

✔ `terraform destroy`
✔ Deleted all cloud resources
✔ Resolved the earlier NIC + Public IP dependency issue

Now you have a fresh environment for the upcoming section.
