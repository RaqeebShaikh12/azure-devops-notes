
# Terraform on Azure – Notes (Set 5)

## 52. Introduction to Input Variables
Input variables allow dynamic values to be passed during Terraform runtime instead of hardcoding.

## 53. Fixing VM Agent Drift Issue
Adding explicit VM agent property prevents repeated drift detection.

## 54. Using terraform.tfvars
terraform.tfvars file allows auto-loading of variable values.

## 55. Adding More Input Variables
Variables for VM size, admin password, and sensitive values.

## 56. Masking Sensitive Variables
sensitive = true hides passwords in output.

## 57. terraform validate command
Used for syntax and consistency validation before plan.

## 58. Creating & Attaching Data Disk
Managed disk + attachment resource.

## 59. Azure Cost Management
Destroy resources when done; use Azure budgets.

## 60. Clean Slate for Next Section
Resources destroyed successfully; ready for next section.
