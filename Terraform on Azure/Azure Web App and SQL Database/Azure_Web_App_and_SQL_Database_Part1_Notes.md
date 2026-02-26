
# Azure Web Apps – Notes (Part of Two PaaS Services Overview)

## 1. What We’re Learning in This Section
We are covering **two Platform‑as‑a‑Service (PaaS)** services:
- **Azure Web Apps**
- **Azure SQL Database**

We will explore how to:
1. Understand the service
2. Deploy a resource using the Azure portal
3. Deploy using **Terraform**

---

## 2. What Is Azure Web App Service?
Azure Web Apps is a **Platform‑as‑a‑Service (PaaS)** for hosting web applications.

**Key idea:** Instead of manually creating VMs + IIS/Apache + patching + updates, Azure Web Apps gives you a **managed environment** where Microsoft handles:
- Physical servers
- Virtual machines
- OS & framework patching
- Network plumbing
- High availability
- Backups (tier‑dependent)

**Supported stacks:** .NET, Java, Node.js, PHP, Python.

---

## 3. When to Use Web Apps vs VMs
- **Use Azure Web App** for standard web apps that fit supported runtimes.
- **Use Virtual Machines** for custom workloads needing non‑standard OS/config or full control.

---

## 4. Deploying a Web App (Portal Flow)
**Steps:**
1. Create a **Web App** in the Azure portal
2. Choose/create a **Resource Group**
3. Provide a **unique app name** → becomes `https://<name>.azurewebsites.net`
4. Publish type: **Code**
5. Runtime stack: e.g., **.NET 8**
6. OS: **Windows** or **Linux**
7. Choose an **App Service Plan** (Free/Shared/Basic/Standard/Premium)

**App Service Plan controls:** hardware size, features, cost, compute infrastructure.

**Free tier limitation:** Web app runs up to **60 minutes/day** and lacks many features.

---

## 5. Viewing/Editing Files in Web App
Use **Development Tools → App Service Editor** to view or upload files on the machine hosting your app (e.g., create `default.html` in the web app root).

---

## 6. Deploying a .NET App from Your Laptop (Quick Path)
1. Install **.NET SDK**
2. VS Code extensions: **C# Dev Kit**, **Azure Tools**
3. Create an **ASP.NET Core** project (Command Palette → “.NET: New Project”)
4. In Azure Tools, right‑click the Web App → **Deploy to Web App**

VS Code builds your project and publishes the output to the Web App. Refresh the site to see the updated app (e.g., *Hello World*).

---

## 7. Terraform Deployment – Clean Setup
Recommended files:
- `main.tf`
- `variables.tf`
- `terraform.tfvars`

Define a **map‑object** input variable to model the environment.

### Example `variables.tf`
```hcl
variable "web_app_environment" {
  type = map(object({
    service_plan = map(object({
      sku     = string
      os_type = string
    }))
    service_app = map(string)
  }))
}
```

### Example `terraform.tfvars`
```hcl
web_app_environment = {
  production = {
    service_plan = {
      "myAppServicePlan" = {
        sku     = "F1"
        os_type = "Windows"
      }
    }
    service_app = {
      "myWebApp12345" = "myAppServicePlan"
    }
  }
}
```

---

## 8. Creating the App Service Plan in Terraform
```hcl
resource "azurerm_service_plan" "appserviceplan" {
  for_each = var.web_app_environment["production"].service_plan

  name                = each.key
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = each.value.os_type
  sku_name            = each.value.sku
}
```

---

## 9. Creating the Web App in Terraform (Windows)
Two resource types exist: `azurerm_windows_web_app` and `azurerm_linux_web_app`.

```hcl
resource "azurerm_windows_web_app" "webapp" {
  for_each            = var.web_app_environment["production"].service_app
  name                = each.key
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  service_plan_id = azurerm_service_plan.appserviceplan[each.value].id

  site_config {
    application_stack {
      current_stack  = "dotnet"
      dotnet_version = "8.0"
    }
  }
}
```

> If you choose Linux, use `azurerm_linux_web_app` and the corresponding Linux application stack options.

---

## 10. The “Always On” & Site Config Drift on Free Tier
With **Free (F1)** plans (shared infrastructure), Terraform may repeatedly show changes under `site_config.virtual_application` even when nothing changed.

**Workaround:** switch to **Basic (B1)** (dedicated VM). This resolves the drift. After switching, you can rely on defaults and typically don’t need to force `always_on = false`.

---

## Quick Recap
- Azure Web Apps is a managed PaaS for common runtimes
- App Service Plan dictates features/cost/compute
- Portal, App Service Editor, and VS Code deployments are straightforward
- Terraform: model environment → create Service Plan → create Web App
- Free tier can cause config drift; Basic tier avoids it

