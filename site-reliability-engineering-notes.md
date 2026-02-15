
# Site Reliability Engineering (SRE) – Complete Notes

This document contains simplified, structured, and terminology‑explained notes covering the concepts, practices, and human aspects of **Site Reliability Engineering (SRE)**.

---

## 1. Introduction to SRE
Organizations increasingly rely on reliable systems. As applications grow more complex and users expect faster updates, balancing **speed** and **stability** becomes difficult.

**Site Reliability Engineering (SRE)** provides an engineering‑based approach to ensure reliability while still shipping updates quickly.

### ✔ What is SRE?
SRE is an engineering discipline focused on ensuring a system achieves the **appropriate level of reliability** sustainably.

Key elements:
- **Reliability**: The core focus
- **Appropriate level**: Not 100%, only what the business needs
- **Sustainable**: Without burning out engineers

---

## 2. Why Reliability Matters
Reliable systems:
- Prevent outages and customer frustration
- Protect revenue and brand reputation
- Enable business continuity

A fast system that crashes is useless; reliability comes first.

### Perfect vs Appropriate Reliability
100% reliability is:
- Extremely expensive
- Often unnecessary
- Impossible without trade‑offs

SRE focuses on **achieving just enough reliability** for the business to succeed.

---

## 3. Sustainability in SRE
SRE emphasizes **human well‑being**:
- Reasonable on‑call schedules
- Reducing unnecessary pages
- Eliminating manual repetitive work

Burnt‑out engineers cannot maintain reliable systems.

---

## 4. SRE in Context (History & DevOps Comparison)

### ✔ Origin
- Created at **Google** in 2003 by Ben Treynor Sloss
- Described as: “What happens when you ask a software engineer to design an operations function.”

### ✔ Relationship with DevOps
Both aim to improve operations but differ:

| SRE | DevOps |
|-----|--------|
| Engineering discipline | Cultural movement |
| Focus on reliability | Focus on collaboration |
| Uses SLIs, SLOs, Error Budgets | No strict methods |
| It's a job role | Not a job title |

They complement each other. SRE works excellently in DevOps‑mature organizations.

---

## 5. Core SRE Principles – Virtuous Cycles

### 🌟 Virtuous Cycle #1: SLIs & SLOs

#### SLIs (Service Level Indicators)
A **quantifiable measure** of system health.
Examples:
- % of successful requests (200 OK)
- Response time
- Throughput

#### SLOs (Service Level Objectives)
A **target level** that SLIs should meet.
Example: “Service must succeed 95% of the time over 30 days.”

#### Error Budgets
Formula:
**Error Budget = 100% – SLO**

If SLO = 95% uptime → Error Budget = 5% downtime allowed.

Uses:
- If reliability < target → pause releases, focus on fixes.
- If reliability > needed → deploy more frequently.

Error budgets keep reliability & innovation balanced.

---

### 🌟 Virtuous Cycle #2: Blameless Postmortems
A postmortem investigates incidents to learn, **not blame**.

Key questions:
- What happened?
- Why did it happen?
- How can we prevent it?

Benefits:
- Encourages honesty
- Reveals true causes
- Strengthens team trust
- Creates a culture of learning

“You can't fire your way to reliability.”

---

## 6. Human Side of SRE – Toil & Work Balance

### ✔ What is Toil?
Toil = manual, repetitive, low‑value operational work.
Examples:
- Restarting servers manually
- Creating accounts manually
- Triage of same repeating issues

SREs **eliminate toil through automation**.

### ✔ Work Balance
SRE guideline:
- **≤ 50% reactive ops work**
- **≥ 50% engineering/project work**

If firefighting exceeds 50%, reliability declines.

---

## 7. Reliability Engineering (Role & Skills)

### ✔ Key Responsibilities of an SRE
- Monitoring and reviewing app performance
- On‑call support & incident response
- Ensuring good logs and diagnostics
- Writing runbooks
- Assisting in support ticket triage
- Adding features & fixing bugs
- Contributing to product roadmap
- Performing live-site reviews

### ✔ Important SRE Skills
- Deep understanding of the application
- Monitoring tools (Application Insights, APM tools)
- Logging best practices & exception handling
- Automation and scripting abilities

---

## 8. Application Insights – Performance Monitoring
Application Insights provides:
- Performance monitoring
- Smart detection alerts
- Dependency tracking
- Diagnostic tools
- User behavior insights

### ✔ Smart Detection Alerts
Triggered when:
- Response times degrade
- Dependency calls slow down
- Only certain users/regions see slowness

Alerts include diagnostics:
- # affected users
- Comparison vs past performance
- Detailed charts on response times
- Dependencies contributing to slowdown

Alerts are suggestions, not guaranteed failures.

---

## 9. Improving Performance – Triage → Diagnose → Improve

### 1️⃣ Triage
Is the issue important?
- How many users affected?
- How critical is the impacted feature?

### 2️⃣ Diagnose
Identify:
- Server slow or overloaded?
- Large or heavy webpage?
- Browser client-side slowdowns?
- External dependency issues?

### 3️⃣ Improve
Fixes include:
- Async loading of files
- Minified scripts/CSS
- Caching
- Co-locating services in one region
- Scaling the server or using autoscaling

---

## 10. Monitoring & Alerting Best Practices

### ✔ Good Alerts Must Be:
- Urgent
- Important
- Actionable
- Real (low false positives)

### ✔ Symptom‑Based Monitoring (Preferred)
Focus on what the **user experiences**, not internal server behavior.

Examples:
- “Page slow” = symptom
- “CPU high” = cause

Users care about:
- Availability
- Latency
- Freshness of data
- Feature functionality

### ✔ Cause‑Based Alerts
Used when symptoms appear too late.
Examples:
- Disk nearly full
- Memory almost exhausted

### ✔ Handling Subcritical Alerts
For non-urgent issues:
- Convert alert → ticket
- Include in daily/weekly reports
- Track via workflow system

### ✔ Playbooks (Runbooks)
Each alert should map to written instructions for handling it.

### ✔ Tracking Alert Quality
- Alerts <50% accurate should be removed or fixed.
- Review alerts weekly/quarterly.

---

## 11. Azure Monitor – Alerting System
Azure alerts consist of:

### ✔ Alert Rule Components
1. **Target Resource** – app, VM, storage, etc.
2. **Signal** – metric, log, event
3. **Criteria** – logic test (e.g., CPU > 70%)
4. **Action Group** – email, SMS, automation trigger

### ✔ Alert Lifecycle
- **New** → issue detected
- **Acknowledged** → someone working
- **Closed** → resolved

Monitor condition (system) is different from alert state (human‑set).

### ✔ All Alerts Dashboard
Shows alerts filtered by:
- Severity
- State
- Resource type
- Time window
- Subscription

### ✔ Managing Alert Rules
From “Manage Alert Rules,” you can:
- Enable/disable rules
- Edit criteria
- Change action groups
- Create new rules

---

## 12. Blameless Postmortems (Deep Dive)
Blameless postmortems encourage:
- Learning, not blaming
- Honest disclosure
- Focus on process/system flaws

Key principles:
- Humans act based on information available at the time
- Hindsight bias must be avoided
- Punishment reduces honesty and damages reliability
- Engineers closest to the incident provide best insight

Goal: Build a **just culture** where learning drives improvement.

---

## Summary
This module explored how SRE:
- Ensures reliability sustainably
- Uses SLIs, SLOs, and error budgets
- Relies on blameless postmortems
- Minimizes toil and burnout
- Uses Application Insights and alerting systems
- Implements strong monitoring practices
- Enables continuous improvement via virtuous cycles

SRE is both a philosophy and an engineering discipline that ultimately helps organizations deliver **fast, reliable, and resilient services**.

---

**End of Notes**
