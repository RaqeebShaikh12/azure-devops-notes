
# Terraform Summary & Core Concepts – Consolidated Notes

## 1. Providers in Terraform
Providers are plugins that allow Terraform to interact with external platforms such as Azure, AWS, GCP, etc. Terraform downloads and manages provider versions using:
- `terraform init` → installs required providers
- `.terraform.lock.hcl` → tracks exact provider versions for reproducibility

Providers must be declared in `required_providers` and configured with necessary authentication (e.g., client ID, secret, tenant ID for Azure).

---

## 2. Using Multiple Providers
Terraform supports multi-cloud deployments. You can define multiple providers (e.g., Azure + AWS) and manage resources from both clouds in a single configuration.

Example:
```hcl
provider "azurerm" { features {} }
provider "aws" {
  region     = "us-east-1"
  access_key = "..."
  secret_key = "..."
}
```

---

## 3. Core Terraform Commands
- **terraform init** → initializes directory, installs providers
- **terraform plan** → shows changes needed to reach desired state
- **terraform apply** → applies changes
- **terraform destroy** → removes resources managed by TF
- **terraform validate** → checks configuration syntax
- **terraform fmt** → formats files
- **terraform init -upgrade** → updates provider versions
- **terraform plan -refresh-only** → refreshes state based on real cloud infra

---

## 4. Terraform State File
Terraform keeps a state file (`terraform.tfstate`) to map configuration resources to real cloud resources.

Useful commands:
```
terraform state list
terraform state show <resource>
```

State enables Terraform to know what exists and what needs changes.

---

## 5. Importing Existing Cloud Resources
If a resource exists in Azure/AWS but not in TF state, you can import it via:

```hcl
import {
  id = "/subscriptions/.../providers/Microsoft.Storage/storageAccounts/example"
  to = azurerm_storage_account.example
}
```

Then apply TF to bring it fully under management.

---

## 6. Built-In Functions
Terraform includes many functions to transform and compute values:

- **max()** → largest number
- **join()** → combine list of strings
- **replace()** → replace substring
- **substr()** → extract substring
- **endswith()** → check ending of string

Use `terraform console` to experiment with functions.

---

## 7. Terraform Data Types
- **string**
- **number**
- **bool**
- **list** → ordered list
- **set** → unordered unique values
- **map** → key/value pairs
- **object** → structured attributes

Example:
```hcl
variable "subnet_info" {
  type = list(object({
    name          = string
    address_prefix = string
  }))
}
```

---

## 8. Input Variables Overview
Variables make Terraform dynamic and reusable.

Ways to provide values:
- terraform.tfvars
- CLI input prompts
- default values
- environment variables

Variables can have **validation rules**:
```hcl
validation {
  condition     = var.vm_count <= 5
  error_message = "VM count cannot exceed 5." }
```

### Lists vs Maps vs Objects
- **list** → access via index
- **map** → access via key
- **list(object)** → ordered complex items
- **map(object)** → keyed complex items

---

## 9. Other Terraform Blocks
### File Reading
Two approaches:

Using `file()`:
```hcl
output "config" { value = file("locals.tf") }
```

Using data block:
```hcl
data "local_file" "config" {
  filename = "locals.tf"
}
```

---

## 10. Terraform Taint / Replace
Old approach:
```
terraform taint
```
New recommended approach:
```
terraform apply -replace="resource.name"
```
This forces Terraform to recreate a specific resource.

---

## 11. Other Key Terraform Concepts
### Data Sources
Fetch information about existing infrastructure (managed or unmanaged).

### Count
Repeats a resource `n` times.
Access via index: `resource[count.index]`

### For_each
Repeats a resource for each element of a map/set.
Access via `each.key` and `each.value`

### Dynamic Blocks
Allows generating nested arguments dynamically.

Example:
```hcl
dynamic "subnet" {
  for_each = var.subnets
  content {
    name = subnet.value
  }
}
```

---

# End of Summary Notes
