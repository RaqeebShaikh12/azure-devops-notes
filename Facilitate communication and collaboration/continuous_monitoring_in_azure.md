
# Continuous Monitoring in Azure – Full Detailed Notes

## 📘 Introduction
Your globally deployed, business‑critical application requires reliable, continuous monitoring. Downtime costs **$10,000 per minute**, and failures must be detected, diagnosed, and resolved instantly.
Continuous Monitoring ensures issues are found early—across development, testing, staging, and production.

This module covers:
- Azure Monitor
- Application Insights
- Dashboards
- Alerts & ticketing (ITSMC)
- Best‑practice monitoring and observability

---

# 🌐 Continuous Monitoring
### Definition
Continuous Monitoring = monitoring every stage of the DevOps lifecycle to validate:
- Health
- Performance
- Reliability

It extends CI/CD by providing **continuous feedback**.

---

# 👁️ Observability
Observability = making system data visible.
Monitoring = collecting & visualizing that data.

Observability requires:
- Logs
- Metrics
- Traces
- Distributed dependency data
- Exceptions

---

# ☁️ Azure Monitor
Azure Monitor provides full‑stack observability across:
- Applications
- Infrastructure
- Containers
- VMs
- Networks
- Storage
- On‑prem & cloud

Key integrations:
- Visual Studio / VS Code
- Azure DevOps
- ITSM tools
- SIEM tools
- Power BI
- Application Insights

---

# 🖥️ Application Monitoring
Enable monitoring for:
- Web apps
- Mobile apps
- Microservices
- APIs

If starting a new project, Azure Developer CLI (**azd**) accelerates setup.

Use Azure Pipelines + Application Insights for live application telemetry.

---

# 🏗️ Infrastructure Monitoring
Azure Monitor tracks:
- CPU, memory, network
- AKS health
- VM performance
- Storage behavior
- Network reliability

Tools:
- **Azure Monitor for VMs**
- **Azure Monitor for Containers**
- **Azure Policy** for compliance
- **ARM templates** for IaC monitoring

---

# 📦 Resource Groups for Observability
Applications consist of:
- VMs / App Service / AKS
- SQL DB / Storage / Event Hubs
- Service Bus / Functions

Group resources logically inside **Resource Groups** → enables:
- End‑to‑end monitoring
- Drill‑down investigations

---

# 🔁 Monitoring in CI/CD
Monitoring should be integrated into pipeline:

### Recommended:
- Azure Pipelines → automate build → test → deploy → verify
- Deployment gates → validate KPIs pre/post deployment
- Separate monitoring per environment
- Use Log Analytics for cross‑resource queries

---

# 📢 Alerts
Azure Monitor alerts must be **actionable**.

### Configure alerts for:
- Logs
- Metrics
- Failures
- Dependencies
- Exceptions

### Alerting features:
- Dynamic thresholds (reduce false positives)
- Action groups:
  - Email
  - SMS
  - Push notification
  - Voice call
  - Webhooks
  - ITSM tickets
  - Automation runbooks (auto‑fix)
- Autoscaling

---

# 📊 Dashboards and Visualization Tools
Teams need shared visibility.

Tools include:
- Azure Dashboards
- Azure Monitor Workbooks
- Application Insights Workbooks
- Power BI
- Grafana
- Custom applications via REST API

---

## 📌 Azure Dashboards
Pros:
- Combine metrics + logs
- Pin views from Insights / Logs / Metrics
- Shared or personal
- Auto‑refresh

Cons:
- Limited log visualization
- No interactivity
- No historical logs >30 days

---

## 📘 Azure Monitor Workbooks
Pros:
- Great for log‑based visuals
- Interactive drill‑down
- Parameter filters
- Import/export

Cons:
- Log only (no metrics)
- No auto‑refresh
- Query & workspace limitations

---

## 🧠 Application Insights Workbooks
Pros:
- Support both metrics + logs
- Highly interactive reports
- Great for troubleshooting guides
- Personal/shared

Cons:
- Not a dense dashboard view
- No auto‑refresh

---

## 📈 Power BI
Pros:
- Highly interactive visualizations
- Long‑term KPI tracking
- Mobile/web sharing
- Combine datasets from anywhere

Cons:
- Refresh limit (≤ 8/day)
- Not tightly integrated with Azure resources

---

## 📉 Grafana
Pros:
- Very rich visualization
- Azure Monitor plugin
- Interactive data exploration

Cons:
- Limited Azure management
- No ARM integration

---

## 🧩 Custom Dashboards
Pros:
- Total UI/UX freedom
- Combine any API or dataset

Cons:
- Engineering heavy
- Must build all interactions manually

---

# 🔎 Application Insights (AI)
Application Insights = an APM tool that monitors app behavior and performance.

### Tracks:
- Requests / response times
- Failures / exceptions
- Dependency performance
- AJAX calls
- Page load times
- User sessions & retention
- Host metrics (CPU/memory)
- Docker logs
- Trace logs
- Custom events & metrics

### Overhead:
Minimal — async, batched, background thread.

---

# 🧰 Application Insights Tools
- **Smart Detection** → anomaly detection
- **Application Map** → dependency visualization
- **Profiler** → performance profiling
- **Usage Analytics** → customer insights
- **Search** → raw telemetry browsing
- **Metrics Explorer** → chart visualizations
- **Live Metrics** → real‑time monitoring
- **Log Analytics** → KQL queries
- **Snapshot Debugger** → debug failing requests
- **Power BI** integration
- **Continuous Export**

---

# 🎟️ IT Service Management Connector (ITSMC)
Integrates Azure alerts with ITSM tools:
- ServiceNow
- Cherwell
- Provance
- System Center Service Manager

### ITSMC enables:
- Ticket creation from alerts
- Syncing incidents & change requests
- Faster troubleshooting (less context switching)
- Log Analytics + ITSM insights

---

# 📘 Summary
Continuous Monitoring:
- Ensures health, performance, reliability
- Detects issues early
- Works across all environments

Azure Monitor:
- Full‑stack observability
- Logs + metrics + diagnostics

Application Insights:
- Deep app telemetry
- Behavior + performance insights

ITSMC:
- Bridges alerts → ticketing → action

Dashboards & Workbooks:
- Provide shared visibility and insights

Overall, continuous monitoring is essential for reliable applications, fast incident response, and data‑driven DevOps.
