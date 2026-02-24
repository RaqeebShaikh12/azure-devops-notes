# Terraform on Azure – Master Notes (Part 1)

## Sections 1–15

### 1. What is Terraform?
Terraform is an Infrastructure as Code (IaC) tool that lets you declaratively define cloud resources.

### 2. Why Use Terraform?
(Notes from earlier sections summarised)

### 3. How Terraform Works (High-level)
- Write
- Plan
- Apply

### 4. Providers
Includes AzureRM provider interaction with APIs.

### 5. Azure Basics
Overview of Azure services.

### 6. Resource Group Creation
Resource block examples, diagrams.

### 7. Authentication & Authorization
Azure CLI + RBAC.

### 8. Service Principal Authentication
Steps for App Registration + Client Secret.

### 9. Storage Account Concepts
Containers, blobs.

### 10. Deploy Storage Account with Terraform
Resource blocks for storage.

### 11. Blob Upload via Terraform
Container + blob resources.

### 12. State Files
.tfstate, backup, .terraform directory.

### 13. Referencing Managed Resources
resource_type.name.property

### 14. Destroy Command
terraform destroy

### 15. Dependency Ordering & depends_on
Explicit vs implicit dependencies.
