# Azure Monitor, Log Analytics, Alerts, RBAC, and Locks — Notes

## 1) Azure Monitor — Overview
Azure Monitor is the central platform to collect, analyze, and act on telemetry from Azure and on‑prem resources.

### Key Concepts
- **Metrics**: Numeric time‑series (e.g., CPU %, Network In/Out, Disk IOPS)
- **Logs**: Detailed event/diagnostic records (Windows Events, Syslog, Activity Logs)
- **Alerts**: Rules that trigger notifications/actions when conditions are met
- **Insights**: Solution packs/dashboards for common resource types (VMs, Containers, SQL, etc.)

### Typical Use Cases
- Detect high CPU or abnormal network throughput
- Investigate security events via collected OS/platform logs
- Trigger automation (Logic Apps, Functions) on alerts

---

## 2) Metric Alerts (Manual → Terraform)

### Manual Flow
1. Pick **Target Resource** (VM)
2. Choose **Metric** (e.g., `Percentage CPU`, `Network In Total`)
3. Define **Condition** (e.g., Average > 80%, every 1 min over the last 5 mins)
4. Create an **Action Group** (email/SMS/webhook/automation)
5. Create the **Alert Rule**

### Terraform Building Blocks
- `azurerm_monitor_action_group` — defines notifications/actions
- `azurerm_monitor_metric_alert` — defines conditions and ties to action group(s)

### Pattern Used
- A **map variable** drives multiple alerts (per‑resource, per‑metric)
- `for_each` + dynamic values fill: namespace, metric name, aggregation, operator, threshold
- **Scope** = target VM’s **resource ID** (exported from the compute module as a map: `{ vmName => vmId }`)

**Example Cases**
- `network_threshold` on `webvm01`: `Network Out Total` > 70 bytes (demo threshold)
- `cpu_threshold` on `appvm01`: `Percentage CPU` > 80%

---

## 3) Log Analytics Workspace (LAW)
A central store for logs and performance data.

### What You Configured
- `azurerm_log_analytics_workspace` — unique workspace name (with `random_integer` suffix)
- Retention/ingestion billed per GB and days kept
- Query via **KQL** in **Logs** blade

**Common Tables after onboarding**
- `Heartbeat` — agent heartbeats
- `Event` — Windows Event Logs
- `Syslog` — Linux syslog (if applicable)

**Sample Query**
```kql
Event
| take 50
```

---

## 4) Data Collection Rule (DCR) + Association
DCR defines **what to collect** and **where to send**.

### Terraform Building Blocks
- `azurerm_monitor_data_collection_rule` — destinations + data sources + flows
- `azurerm_monitor_data_collection_rule_association` — attach DCR to VMs

### What You Deployed
- Source: **Windows Event Logs** (Security/System) via XPath selector (all levels)
- Destination: **LAW** (the workspace created above)
- Associated to **both Windows Server 2022 VMs**
- Data appears in ~15–20 minutes

---

## 5) Identity (Microsoft Entra ID) & RBAC

### Concepts
- **Entra ID (Azure AD)**: users, groups, apps/service principals
- **RBAC**: Assign **roles** to **principals** at a **scope** (Subscription / RG / Resource)

### Common Roles
- **Owner** — full control (incl. role assignments)
- **Contributor** — manage resources (no role assignment rights)
- **Reader** — read‑only
- Service‑specific: **Virtual Machine Contributor**, **Storage Blob Data Contributor**, etc.

### Terraform Building Blocks
- `azuread_user` — creates cloud users
- `azurerm_role_assignment` — grants role at a scope to a principal

### Practical Notes
- Your Terraform SP needed **User Administrator** to create users
- And **User Access Administrator** to assign RBAC on Azure resources
- Scope pattern used:
  `/subscriptions/{subId}/resourceGroups/{rg}/providers/{resourceType}/{resourceName}`

### Pattern Used
- **Map variable** of users → includes directory (UPN suffix), password, target `resource_type`, `resource_name`, and `role`
- `for_each` to create users and assign roles programmatically

---

## 6) Resource Locks
Protect resources from accidental deletes/changes.

### Types
- **CanNotDelete** — updates allowed; delete blocked
- **ReadOnly** — no updates or deletes

### Terraform
- `azurerm_management_lock` applied over a list of targets (VMs, VNets, etc.)
- Scope built using subscription id + resource group + resource type + resource name

**Example Targets**
- `webvm01` → `CanNotDelete`
- `app-vnet` → `ReadOnly`

---

## 7) Text Diagrams

### Monitoring Flow
```
VMs → Metrics → Azure Monitor → Alerts → Action Group → Email / Logic App / Function
```

### Log Ingestion
```
Windows VM → Data Collection Rule → Log Analytics Workspace → KQL Queries / Dashboards
```

### RBAC Scope
```
Subscription
└─ Resource Group
   └─ Resource
```

---

## 8) Quick Terraform Snippets (Illustrative)

### Action Group (email)
```hcl
resource "azurerm_monitor_action_group" "email_ag" {
  name                = "ag-email"
  resource_group_name = var.resource_group_name
  short_name          = "alertmail"

  email_receiver {
    name          = "ops"
    email_address = var.alert_email
  }
}
```

### Metric Alert (looped)
```hcl
resource "azurerm_monitor_metric_alert" "alerts" {
  for_each            = var.metric_alerts
  name                = each.key
  resource_group_name = var.resource_group_name
  description         = "${each.key}: ${each.value.metric_name} > ${each.value.threshold}"
  scopes              = [var.vm_details[each.value.scope].id]

  criteria {
    metric_namespace = each.value.metric_namespace
    metric_name      = each.value.metric_name
    aggregation      = each.value.aggregation
    operator         = each.value.operator
    threshold        = each.value.threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.email_ag.id
  }
}
```

### Log Analytics Workspace
```hcl
resource "random_integer" "ws_suffix" {
  min = 10000
  max = 99999
}

resource "azurerm_log_analytics_workspace" "ws" {
  name                = "vm-ws-${random_integer.ws_suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
```

### DCR and Association (conceptual)
```hcl
resource "azurerm_monitor_data_collection_rule" "win_dcr" {
  name                = "win-events"
  location            = var.location
  resource_group_name = var.resource_group_name

  destinations {
    log_analytics {
      name                  = "law"
      workspace_resource_id = azurerm_log_analytics_workspace.ws.id
    }
  }

  data_sources {
    windows_event_log {
      name           = "system"
      x_path_queries = ["Security!*[System[(Level>=0)]]", "System!*[System[(Level>=0)]]"]
    }
  }

  data_flows {
    streams      = ["Microsoft-WindowsEvent"]
    destinations = ["law"]
  }
}

resource "azurerm_monitor_data_collection_rule_association" "assoc" {
  for_each               = var.vm_details
  name                   = "assoc-${each.key}"
  target_resource_id     = each.value.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.win_dcr.id
}
```

### RBAC — User + Assignment
```hcl
data "azurerm_subscription" "current" {}

resource "azuread_user" "u" {
  for_each           = var.user_list
  user_principal_name = "${each.key}@${each.value.directory}"
  display_name        = each.key
  password            = each.value.password
  force_password_change = true
}

resource "azurerm_role_assignment" "u_role" {
  for_each             = var.user_list
  scope                = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/${each.value.resource_type}/${each.value.resource_name}"
  role_definition_name = each.value.role
  principal_id         = azuread_user.u[each.key].object_id
}
```

### Resource Locks
```hcl
resource "azurerm_management_lock" "locks" {
  for_each = var.resource_locks
  name     = "lock-${each.key}"
  scope    = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/${each.value.type}/${each.value.name}"
  lock_level = each.value.level # "CanNotDelete" or "ReadOnly"
}
```

---

## 9) Operational Tips
- Give your Terraform SP only the **minimum** Entra ID permissions required and remove them after use
- Use `lifecycle { ignore_changes = [...] }` to reduce noisy VM diffs not relevant to monitoring
- Tag all monitoring assets (e.g., `env = prod`, `owner = platform`) for quick filtering
- For production alerts, tune **thresholds**, **evaluation periods**, and **frequency** to avoid alert fatigue

---

*End of notes.*
