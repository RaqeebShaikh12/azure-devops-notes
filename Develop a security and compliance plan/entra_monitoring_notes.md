
# Microsoft Entra Monitoring & Log Analytics – Simplified Notes

## 1. Introduction – Why Monitoring Matters
When a company uses Microsoft Entra ID, identities control access to all cloud resources. If an attacker compromises one user account, they can access confidential systems. Monitoring sign-in logs, audit logs, and risky sign-ins helps detect suspicious activity early.

Azure provides tools like Log Analytics Workspace, Azure Monitor, alerts, and dashboards to detect abnormal behavior and respond quickly.

---

## 2. Microsoft Entra Logs
Microsoft Entra provides several log types:

### **Sign-in Logs**
These track every user sign-in attempt. They show:
- Whether the sign-in succeeded or failed
- Location (country/IP)
- Device information
- Application accessed
- MFA status

Useful for finding unusual behavior like sign-ins from unfamiliar locations.

### **Audit Logs**
These track actions done *after* a user signs in. Example events:
- Password reset
- Role assignment
- App registration
- Group creation

Useful for detecting unauthorized administrative activity.

---

## 3. Sign-in Logs in Detail
You can customize columns (location, device, MFA result) and apply filters (status, app, date).

### Common Use Cases:
- Failed MFA attempts → possible account attack
- New login country → risky sign-in
- Attempts to access restricted apps

### Common Error Codes:
- **50055** – Password incorrect or expired
- **50057** – User account disabled
- **50074** – MFA challenge failed
- **50126** – Invalid username/password
- **53003** – Conditional Access blocked login

---

## 4. Audit Logs in Detail
Audit logs record:
- What action was taken
- Who performed it
- When it happened
- Whether it succeeded

Filters can reduce huge log sets to specific:
- Time ranges
- Services (User Management, Groups, Apps)
- Activity types
- Specific actors

---

## 5. Why Use Log Analytics Workspace?
Log Analytics Workspace allows:
- Centralized storage of sign-in & audit logs
- Advanced querying using Kusto Query Language (KQL)
- Creating alerts
- Creating dashboards and reports

Azure Monitor reads logs **from this workspace**, so sending logs to it is essential.

---

## 6. Creating a Log Analytics Workspace
1. Go to Azure Portal → "Log Analytics Workspace"
2. Create new workspace
3. Provide name, region, resource group
4. Save workspace

A workspace is a central repo for log data.

### Storage Size Example:
- 1,000 users → 15,000 audit events/day → ~30 MB/day
- 1,000 users → 34,800 sign-in events/day → ~140 MB/day

---

## 7. Sending Logs to Log Analytics
1. Go to Microsoft Entra → Monitoring → Diagnostics Settings
2. Add diagnostic setting
3. Choose:
   - Sign-in Logs
   - Audit Logs
4. Select "Send to Log Analytics"
5. Choose workspace

After 15 minutes, logs begin appearing.

---

## 8. Kusto Query Language (KQL) Basics
A KQL query:
- Always starts with the table name
- Uses pipes (|) to chain commands
- Can filter, sort, summarize, and project columns

### Common KQL Commands:
- `where` – filter data
- `sort by` – order results
- `summarize` – aggregate
- `take` – top N rows
- `project` – select specific fields

### Example Queries:

Most used apps (last 7 days):
```kusto
SignInLogs
| where CreatedDateTime >= ago(7d)
| summarize signInCount = count() by AppDisplayName
| sort by signInCount desc
```

Risky sign-ins (last 14 days):
```kusto
SignInLogs
| where CreatedDateTime >= ago(14d)
| where isRisky == true
```

Most common audit events (last 7 days):
```kusto
AuditLogs
| where TimeGenerated >= ago(7d)
| summarize auditCount = count() by OperationName
| sort by auditCount desc
```

---

## 9. Workbooks & Templates
Workbooks allow you to visualize data (charts, tables, graphs). You can:
- Use built-in templates
- Modify queries
- Save custom dashboards

---

## 10. Setting Alerts in Log Analytics
Alerts help you detect risky events in real time.

Steps:
1. Azure Monitor → Alerts → Create Alert Rule
2. Set scope to Log Analytics Workspace
3. Add Condition (KQL query triggers alert)
4. Add Action Group (email, SMS, webhook)
5. Create alert

Examples:
- Too many failed sign-ins
- Multiple risky sign-ins in an hour
- Admin role changes

---

## 11. Creating Dashboards
Dashboards give a visual overview of:
- Sign-in attempts
- Risky users
- Audit activities
- Alerts

Steps:
1. Azure Portal → Dashboard → New Dashboard
2. Add tiles
3. From Log Analytics → pin query results to dashboard

---

## 12. Exporting Reports
You can export query results to:
- CSV
- Excel
- Power BI (M Query)

Power BI allows building interactive reports for leadership.

---

## 13. Summary
With Microsoft Entra logs + Log Analytics + Alerts + Dashboards, you can:
- Detect suspicious login behavior early
- Monitor user activities
- Get real-time alerts on risky events
- Build dashboards for continuous monitoring

These tools help prevent identity-based breaches and strengthen security posture.

