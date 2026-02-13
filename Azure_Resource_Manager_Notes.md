
# Azure Resource Manager, Resource Groups, Telemetry, Tags, Policies, RBAC & Resource Locks – Master Notes

---

## 1. Telemetry Overview

### What is Telemetry?
Telemetry is the **automated collection, transmission, and monitoring of data** from distributed or remote systems.

### Purpose of Telemetry
- Provides **visibility** into system behavior  
- Enables **monitoring** and **alerting**  
- Helps with **performance optimization**  
- Identifies **failures**, **bottlenecks**, & **security issues**  
- Supports **resource optimization** and **capacity planning**

### Key Concepts
| Concept | Description |
|--------|-------------|
| **Logging** | Captures discrete events (errors, requests, exceptions) |
| **Telemetry** | Continuous flow of system metrics & diagnostics |
| **Monitoring** | Tools and dashboards to visualize telemetry & logs |

### Why It Matters in Azure
- Azure services produce metrics/logs through **Azure Monitor**
- Helps detect outages, analyze performance, and troubleshoot
- Supports DevOps practices like observability, SRE, and automation

---

## 2. Azure Resource Manager (ARM)

Azure Resource Manager is the **deployment and management layer** for Azure.

### Key Capabilities
- **Organize resources** using *resource groups*
- **Apply policies** for compliance and governance
- **Use RBAC** to scope access at resource/group/subscription level
- **Protect resources** using *resource locks*
- **Deploy infrastructure as code** using ARM templates or Bicep

---

## 3. Understanding Resource Groups

### What Are Resource Groups?
A **resource group (RG)** is a logical container for Azure resources (VMs, VNets, DBs, etc.).

### Important Rules
- Every resource **must** belong to one (and only one) RG  
- Resource groups **cannot be nested**  
- Most resources can be **moved** to another RG (some limitations apply)  
- Deleting a RG deletes **all resources inside it**

### Purpose of Resource Groups

#### 1. Logical Organization
Group resources by:
- Type (VMs, VNets, Databases)
- Department (Finance, HR)
- Environment (Prod, QA, Dev)
- Application or Project

#### 2. Resource Lifecycle Management
- Deleting the RG deletes everything inside  
  → Useful for test environments, temporary projects

#### 3. RBAC Authorization
Apply permissions at RG level:
- Database team → DB resource group  
- Network team → VNet resource group  

Simplifies management and security.

#### 4. Billing
Usage can be grouped by RG for better cost analysis.

---

## 4. Creating a Resource Group (Portal)

### Steps
1. Open **Azure Portal**
2. Select **Create a resource**
3. Search for **Resource Group**
4. Click **Create**
5. Provide:
   - Subscription  
   - Resource Group name (e.g., `msftlearn-core-infrastructure-rg`)  
   - Region  
6. Click **Review + Create**
7. Click **Create**

---

## 5. Exploring Resource Groups

Inside the RG overview page, you see:
- Subscription & RG info
- Tags applied
- Deployment history
- List of resources within the RG
- Actions: **Add**, **Move**, **Delete**, **Assign tags**

---

## 6. Adding Resources to a Resource Group

**Example: Creating a Virtual Network (VNet)**

1. Go to the resource group  
2. Click **Create**  
3. Search **Virtual Network**  
4. Set:
   - Resource Group: `msftlearn-core-infrastructure-rg`
   - Name: `msftlearn-vnet1`
5. **Review + Create**

Repeat to create `msftlearn-vnet2`. Both VNets appear in the RG.

---

## 7. Best Practices for Resource Group Organization

### ✔ Consistent Naming Convention
```
<project>-<purpose>-<environment>-rg
```

**Example:** `msftlearn-core-infrastructure-rg`

### ✔ Organizing Models

**By Resource Type**
- vnet-rg  
- vm-rg  
- db-rg  

**By Environment**
- prod-rg  
- qa-rg  
- dev-rg  

**By Department**
- finance-rg  
- marketing-rg  
- hr-rg  

**Combined Strategy**
- prod-finance-rg  
- dev-marketing-rg  

### ✔ Organize for
- Security (RBAC)
- Lifecycle (delete RG = delete resources)
- Billing (cost grouping)

---

## 8. Azure Tags

### What Are Tags?
Tags are **key-value pairs** assigned to RGs or individual resources.

**Examples:**
```
Department = Finance
Environment = Production
CostCenter = CC101
```

### Tag Rules
- Up to **50 tags per resource**
- Tag name limit: 512 chars (128 for Storage Accounts)
- Tag value limit: 256 chars
- Not inherited automatically from RG
- Classic resources may not support tags

---

## 9. Adding Tags (Portal)

### Steps
1. Go to the resource group  
2. Add **Tags** column to the view  
3. For each VNet:
   - **… → Edit Tags**  
   - Add: `Department = Finance` (vnet1), `Department = Marketing` (vnet2)

### Bulk Tagging
- Select multiple resources → **Assign Tags**  
- Add: `Environment = Training`

---

## 10. Use Cases for Tags

### ✔ Billing Organization
Group resources by **CostCenter**, **Department**, **Environment**

### ✔ Filtering & Searching
Find all resources tagged with `Environment = Training` (across RGs)

### ✔ Monitoring
Alerts can include tags → know which teams are impacted

### ✔ Automation
Use tags to start/stop VMs, target backups, etc.

**Example:**
```
Shutdown = 6PM
Startup  = 7AM
```

---

## 11. Use Policies to Enforce Standards

### What is Azure Policy?
Azure Policy is a governance service to **create, assign, and manage** policy rules for compliance and standardization. Policies validate **new** and **existing** resources.

**Common Enforcements**
- Require tags (Department/Environment)
- Restrict regions
- Restrict VM sizes
- Enforce naming conventions
- Block disallowed resources

---

### Create a Custom Policy (Portal)

**1) Create Policy Definition**
- Portal → **Policy** → **Definitions** → **+ Policy definition**
- **Name:** Enforce tag on resource  
- **Description:** This policy enforces the existence of a tag on a resource.  
- **Category:** General  
- **Policy rule:**

```json
{
  "mode": "Indexed",
  "policyRule": {
    "if": {
      "field": "[concat('tags[', parameters('tagName'), ']')]",
      "exists": "false"
    },
    "then": {
      "effect": "deny"
    }
  },
  "parameters": {
    "tagName": {
      "type": "String",
      "metadata": {
        "displayName": "Tag Name",
        "description": "Name of the tag, such as 'environment'"
      }
    }
  }
}
```

**2) Assign the Policy**
- **Assignments** → **Assign policy**  
- **Scope:** `msftlearn-core-infrastructure-rg`  
- **Policy definition:** *Enforce tag on resource*  
- **Parameter:** `Tag name = Department`  
- **Review + Create**

**3) Test the Policy**
- Create **Storage account** in the RG without `Department` tag → **Validation fails**  
- Add tag: `Department: Finance` → **Validation succeeds**  
- ⚠️ Policy assignment can take **up to 30 minutes** to take effect

---

## 12. Additional Uses of Azure Policy

- **Region restrictions** for data residency & compliance  
- **VM size restrictions** to control costs in Dev/Test  
- **Naming conventions** to maintain consistency

---

## 13. Secure Resources with Role‑Based Access Control (RBAC)

RBAC provides **fine‑grained access control** for Azure resources.

### Why RBAC?
- Protect resources from unauthorized actions  
- Assign only required permissions  
- Avoid broad, unnecessary access

### Examples
- One user manages VMs; another manages VNets  
- DBA group manages SQL databases  
- Developer team gets **read‑only**  
- Apps granted access to only required resources

### Where to Manage
- **Resource → Access control (IAM)**: view role assignments, add/remove access

### Access Model
RBAC uses an **allow model**. Combined role assignments add up:  
Read (from one role) + Write (from another) ⇒ **Read + Write**

### Best Practices
- **Least privilege**  
- **Separate duties**  
- Assign roles at the **lowest scope** necessary  
- Use **resource locks** for extra protection

---

## 14. Resource Locks

### What Are Resource Locks?
Prevent accidental modification/deletion.

| Lock Type | Restriction |
|-----------|-------------|
| **Delete** | Cannot delete the resource |
| **Read‑only** | Cannot modify or delete the resource |

**Scopes:** Subscription, Resource Group, Resource  
**Inheritance:** Locks apply to child resources

### Important Notes
- **Read‑only** may block operations that use POST under the hood (e.g., list keys for Storage Account)
- Locks apply **regardless of RBAC**; even Owners must remove locks to proceed

### Create a Resource Lock
1. Open RG: `msftlearn-core-infrastructure-rg`  
2. **Settings → Locks → + Add**  
3. **Name:** `BlockDeletion`  
4. **Type:** `Delete`  
5. **Save**

**Test:** Try deleting `msftlearn-vnet1` → deletion is blocked.  
Remove the lock at RG level to proceed with deletion.

### When To Use Locks
- VNets, ExpressRoute circuits, critical databases, domain controllers, prod storage

---

## 15. Clean Up Resources

1. Delete the **resource group** `msftlearn-core-infrastructure-rg`
2. In **Policy → Assignments**, remove the assignment (if not already removed by RG deletion)
3. In **Policy → Definitions**, delete the custom definition: *Enforce tag on resource*

---

**End of Master Notes**
