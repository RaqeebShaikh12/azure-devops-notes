
# Azure Monitor for Virtual Machines — Complete Notes

## Scenario Overview
You're the IT admin for a band's mission-critical website hosted on Azure Virtual Machines (VMs)...

## What is Azure Monitor?
Azure Monitor collects Metrics and Logs to monitor VM performance...

## Metrics
- Numerical values like CPU%, disk usage
- Automatically collected for 93 days

## Logs
- Event-based records stored in Log Analytics workspace

## VM Monitoring Layers
1. Host VM
2. Guest OS
3. Workloads
4. Applications

## Host VM Monitoring
Built-in metrics: Availability, CPU avg, Disk bytes, Network total, Disk ops/sec

## Metrics Explorer
Used to graph metrics, compare across VMs, apply aggregations

## Recommended Alerts
Predefined alert rules for CPU, memory, disk, network, and VM availability

## Activity Logs
Track operations like VM start/stop, resizing, configuration changes

## Boot Diagnostics
Provides startup screenshots + serial logs for troubleshooting

## Guest OS & Application Monitoring
Uses Azure Monitor Agent + Data Collection Rules (DCR)

## VM Insights
Simplified onboarding for guest OS monitoring
- Installs AMA
- Creates DCR
- Shows performance workbooks
- Offers dependency maps

## Custom Log Collection using DCR
Steps:
1. Create Data Collection Endpoint
2. Create Data Collection Rule
3. Add Linux Syslog
4. Send to Log Analytics

## Log Analytics (KQL)
Example queries:
```
Syslog
```
Filter warnings:
```
Syslog | where SeverityLevel == "warning"
```

## Summary
Azure Monitor enables complete host + guest monitoring with alerts, metrics, logs, VM insights, and KQL analytics.
