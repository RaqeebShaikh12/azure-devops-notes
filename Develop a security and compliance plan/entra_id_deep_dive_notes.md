
# Microsoft Entra ID – Complete Simplified Notes (Module Deep Dive)

## 1. Why Identity Management Matters
- Cloud migration requires securing resources, identifying users, and controlling access.
- Microsoft Entra ID helps enforce single sign-on, MFA, centralized identity, least privilege, and automated access removal.

## 2. What is Microsoft Entra ID?
- Cloud-based identity & access management (IAM) service.
- Not a cloud replacement for Windows Server AD.
- Can be used stand‑alone or integrated with on‑prem AD (via Entra Connect).

## 3. Directories, Tenants, and Subscriptions
- **Directory/Tenant:** Identity container storing users, groups, apps.
- **Subscription:** Billing entity using a single Entra directory.
- One directory can have multiple subscriptions.

## 4. Creating a New Directory
- Azure Portal → Create Resource → Microsoft Entra ID → Provide name, initial domain, region.
- A new tenant is created with free-tier features.

## 5. User Types in Entra ID
### Cloud Identities
- Created directly in Entra.

### Directory-Synced Identities
- Synced from on-prem AD using Entra Connect.

### Guest Users
- External partners/vendors invited via email.

## 6. Adding Users
- Methods: Entra Admin Center, Azure Portal, Sync via AD, PowerShell, CLI, Graph API.
- Bulk creation possible via CSV + PowerShell.

## 7. Groups in Entra ID
### Security Groups
- Used for permission assignment.

### Microsoft 365 Groups
- Collaboration: mailbox, SharePoint, Planner.

### Group Membership Types
- Assigned, Dynamic User, Dynamic Device.
- Dynamic groups require P1.

## 8. RBAC (Role-Based Access Control)
- Controls access to Azure resources.
- Built-in roles: Owner, Contributor, Reader.
- Roles defined with Actions, NotActions, DataActions.
- Custom roles require P1/P2.

## 9. Microsoft Entra Connect (Hybrid Identity)
- Sync on-prem AD to cloud.
- Provides PHS, PTA, Federation.
- Includes sync services, health monitoring, optional ADFS.

## 10. Benefits of Hybrid Identity
- Single identity for cloud + on-prem.
- Seamless SSO.
- Centralized management.

## 11. Summary
Microsoft Entra ID provides secure identity, MFA, SSO, guest collaboration, hybrid identity, RBAC, and group/role management across Azure, M365, and SaaS apps.
