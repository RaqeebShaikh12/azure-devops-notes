
# Learning From Failure – Post‑Incident Review (PIR) – Simplified Notes

## 1. Why Learn From Incidents?
Incidents initially feel like disruptions, but after resolving them, they become valuable learning opportunities. A post‑incident review transforms the incident from a loss into an investment in reliability.

Learning helps you:
- Understand system behavior under stress
- See hidden flaws you didn’t know existed
- Improve processes and detection
- Strengthen team decision‑making

Complex systems *will* fail. The goal is to learn from these failures.

---

## 2. Complex Systems Fail – Key Principles
Modern cloud systems are inherently complex.

- **Multiple latent failures always exist**
- **Systems run in degraded mode** without showing visible symptoms
- **Catastrophic failure is always possible** due to complexity
- **Humans are part of the system**, not outside observers

Reliability requires focusing on both **prevention** and **response**.

---

## 3. Why Language Matters
Words influence mindset during reviews.
Negative language leads to blame and hides deeper system issues.

Resilience Engineering teaches us:
- Avoid blame language
- Avoid hindsight bias
- Avoid oversimplified cause-and-effect thinking

We aim for **understanding**, not **judgment**.

---

## 4. What Is a Post‑Incident Review?
A PIR is a structured learning session after an incident.

Incident lifecycle phases:
1. Detection
2. Response
3. Remediation
4. **Analysis (PIR)**
5. Readiness

### Key rules:
- Do PIR **within 24–36 hours**
- Include **everyone** who participated
- Must be **blameless**

Main purpose: **learn how the system and people behaved so you can improve reliability**.

---

## 5. What PIR Is NOT
A good PIR is not:
- ❌ A document only
- ❌ A blame session
- ❌ A search for a single root cause
- ❌ A checklist of action items

It *is* a conversation that builds a shared understanding.

---

## 6. Characteristics of a Good PIR
A strong PIR has:
- **Blamelessness**
- **Multiple perspectives**
- **Curiosity**
- **Honest discussion**

The “4 Ds”:
- Discussion
- Discourse
- Dissent
- Discovery

These ensure deep learning rather than shallow explanations.

---

## 7. PIR Process – How to Conduct One
### Step 1: Gather Data
Collect:
- Chat logs
- Monitoring dashboards
- Alerts
- Logs and events
- Change history

### Step 2: Reconstruct the timeline
Incidents are nonlinear—multiple people act simultaneously.

### Step 3: Hold the review meeting
Use a facilitator, limit to 60–90 mins, keep discussion focused.

---

## 8. Common Traps to Avoid
### Trap 1: Human Error
Human error is a **symptom**, not a cause.
Dig deeper to find systemic contributors.

### Trap 2: Counterfactuals
Avoid “should have,” “could have,” “if only.”
They describe events that *did not happen* and distract from learning.

### Trap 3: Normative Language
Words like “carelessly” or “properly” use hindsight and judgment.

### Trap 4: Mechanistic Reasoning
The idea that systems would work fine “if not for one person.”
In reality, humans keep systems running.

---

## 9. Helpful Practices
### Practice 1: Facilitated Reviews
Use a neutral facilitator to guide discussion.

### Practice 2: Ask Better Questions
Use “what” and “how,” not “why.”

### Practice 3: Ask What Went Right
Learn from successes, not just failures.

### Practice 4: Keep Review vs Planning Separate
Do PIR first → plan fixes later.

---

# Incident Response – Simplified Notes

## 1. Importance of Incident Response
Monitoring detects issues. Incident response is what you do when something breaks.

High-performing teams respond quickly and have a defined plan.
Good incident response reduces downtime and increases reliability.

---

## 2. What Is an Incident?
A **service disruption** impacting user experience.
Examples:
- Slow API
- Website down
- Payment system outages

Not all internal issues are incidents—only customer-impacting ones.

---

## 3. Incident Response vs Reaction
**Reaction** = panic, chaos, unplanned actions
**Response** = structured, coordinated, informed actions

A good response plan helps teams:
- Diagnose quickly
- Triage severity
- Engage correct people
- Communicate clearly
- Restore service fast

---

## 4. Measuring Response Performance – TTR
TTR = Time to Recover / Restore

DORA findings:
- Elite teams restore in < 1 hour
- Medium: < 24 hours
- Low: 1 week – 1 month

Elite teams recover **2604x faster** because they have strong processes.

---

## 5. Incident Lifecycle
1. Detection
2. Response
3. Remediation
4. Analysis (PIR)
5. Readiness

This cycle improves over time as learning accumulates.

---

## 6. Foundations of Incident Response
Built on three pillars:

### 1. Rosters
List of who is on-call.

### 2. Roles
- Primary responder
- Secondary responder
- SMEs
- Incident commander
- Scribe
- Communications coordinator

### 3. Rotations
Schedules to ensure 24/7 coverage.
Models:
- 24x7 shifts
- Follow-the-sun
- Hybrid

---

## 7. Tracking Incidents
Ask:
- When did we know?
- How did we learn?
- Who knew first?
- What's being done?
- How bad is it?

Use centralized systems:
- Azure Boards
- Jira
- ServiceNow

Also create a dedicated incident chat (Teams/Slack).

---

## 8. Automating Incident Launch
Use Logic Apps to automate:
- Creating incident tickets
- Creating Teams channels
- Assigning responders
- Posting updates

Automation improves response speed.

---

## 9. Communication & Collaboration (ChatOps)
Good communication affects every incident phase.
Use group chat to:
- Share real-time updates
- Increase visibility
- Capture decisions for PIR
- Enable team learning

Teams works well for ChatOps.

---

## 10. Remediation – Fixing the Problem
Key steps:
- Provide responders with helpful context
- Provide easy access to dashboards/logs
- Use troubleshooting guides
- Communicate status updates clearly

Communication template:
1. What we know
2. What we’re doing
3. When the next update will be

---

## 11. Helpful Tools
- Azure Monitor Workbooks
- Application Insights (Application Map, Dashboards)
- Log Analytics for deep queries

Workbooks can display:
- Live metrics
- KQL query results
- Documentation links

These tools speed up root-cause identification.

---
