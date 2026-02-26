
# Azure Web Apps – Advanced Terraform Concepts (Part 2)

## 1. Handling the Persistent `virtual_application` Drift Issue
On Free (F1) App Service plans, Azure auto‑generates values inside `site_config.virtual_application` that Terraform cannot consistently track. This results in Terraform always showing changes, even when nothing was modified.

### Why?  
- Azure computes certain fields server-side on shared infrastructure.  
- Terraform expects consistent state values.  
- F1 introduces non‑deterministic defaults → Terraform proposes updates repeatedly.

### Incorrect Fix (Not Recommended)
Upgrading SKU to **B1** eliminates drift but is **not correct** solely to satisfy Terraform.

### Correct Fix → Use lifecycle ignore
```hcl
lifecycle {
  ignore_changes = [
    site_config
  ]
}
```
This avoids drift without changing infrastructure.

---

## 2. Why Manually Defining `virtual_application` Fails
Attempts such as:
- `virtual_application = null`
- manually copying Azure defaults

fail because Azure requires nested values that Terraform cannot infer on F1 tiers.

Use `ignore_changes` instead.

---

## 3. Tagging Azure Resources (Using Variables & Locals)
Tags help with:
- Cost breakdown
- Organization-wide search
- Chargeback
- Ownership tracking

### A) Tagging with Input Variables
```hcl
variable "resource_tags" {
  type = object({
    tags = object({
      department = string
      tier       = string
    })
  })
}
```

`terraform.tfvars`
```hcl
resource_tags = {
  tags = {
    department = "Logistics"
    tier       = "Tier2"
  }
}
```

Usage:
```hcl
tags = var.resource_tags.tags
```

### B) Tagging with Locals
```hcl
locals {
  production_tags = {
    production_code = "${var.resource_tags.tags.department}-${var.resource_tags.tags.tier}"
    production_tier = var.resource_tags.tags.tier
  }
}
```

Usage:
```hcl
tags = local.production_tags
```

---

## 4. Input Variables vs Local Variables
| Feature | Input Variables | Local Variables |
|--------|-----------------|-----------------|
| Purpose | External input | Internal computation |
| Set by | User/tfvars | Terraform only |
| Override? | Yes | No |
| Good for | Names, SKUs, RGs, Env | Derived values, tag composition, expressions |

Rule: **Environment decides → variable. Internal calculation → local.**

---

## 5. Debugging Terraform
Terraform supports detailed logging.

### Enable logging (PowerShell):
```powershell
$env:TF_LOG="DEBUG"
$env:TF_LOG_PATH="C:\terraform\terraform.log"
terraform plan
```

Then inspect `terraform.log` to see all provider requests.

Stop logging by closing the terminal.

---

## 6. Deployment Slots (Concept)
Deployment slots allow zero‑downtime deployments:
- Test new version in **staging** slot
- Swap with **production** slot
- Rollback easily

Requires **S1 or higher** App Service Plan.

---

## 7. Creating Deployment Slots via Terraform
`terraform.tfvars`
```hcl
web_app_slot = ["mywebapp123", "staging"]
```

Creating a slot:
```hcl
resource "azurerm_windows_web_app_slot" "slot" {
  name           = var.web_app_slot[1]
  app_service_id = azurerm_windows_web_app.webapp[var.web_app_slot[0]].id

  site_config {
    application_stack {
      current_stack  = "dotnet"
      dotnet_version = "8.0"
    }
  }

  depends_on = [azurerm_service_plan.appserviceplan]
}
```

---

## 8. Slot Swapping (Promoting Staging → Production)
```hcl
resource "azurerm_web_app_active_slot" "active" {
  slot_id = azurerm_windows_web_app_slot.slot.id
}
```
A swap makes the staging version live immediately.

---

## 9. Logging Web App Requests to Azure Storage (With SAS)
Steps:
1. Create Storage Account + Container  
2. Generate SAS token using Terraform data source  
3. Attach SAS URL in `site_config.logs`  
4. Apply retention period

### SAS Block
```hcl
data "azurerm_storage_account_sas" "sas" {
  connection_string = azurerm_storage_account.logs.primary_connection_string
  https_only   = true
  start        = "2026-02-01"
  expiry       = "2026-02-29"
  services     = ["b"]
  resource_types = ["s","c","o"]
  permissions  = ["l","r","w","a","c","d"]
}
```

### Logging Block
```hcl
site_config {
  logs {
    detailed_error_messages = true

    http_logs {
      azure_blob_storage {
        sas_url = "https://${azurerm_storage_account.logs.name}.blob.core.windows.net/${azurerm_storage_container.weblogs.name}${data.azurerm_storage_account_sas.sas.sas}"
        retention_in_days = 7
      }
    }
  }
}
```

Result: Logs stored in blob container, rotated daily.

---

# End of Part 2 Notes
