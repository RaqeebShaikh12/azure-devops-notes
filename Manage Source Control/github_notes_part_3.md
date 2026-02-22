# GitHub Notes – Part 3 (GitHub Apps, OAuth Apps, Tokens & GitHub Script)

## 📘 GitHub Apps, OAuth Apps & Access Tokens

### 🧩 1. What Are GitHub Apps?
GitHub Apps are integrations that automate tasks, enhance workflows, enforce policies, and reduce manual work.
They can be:
- Installed on specific repositories or orgs
- Granted granular permissions
- Used as CI/CD bots or automation tools

GitHub Apps act as a **service identity**, not a user.

🧠 Example: Automatically closing stale PRs.

---

### 🚦 2. Extending GitHub Using the API
GitHub exposes a REST API used to:
- Manage issues, PRs, labels
- Trigger workflows
- Modify repository content
- Automate reviews
- Integrate CI/CD

API access is packaged through either:
- **GitHub Apps**
- **OAuth Apps**

---

### 🔑 3. OAuth Apps vs GitHub Apps (Key Differences)

#### 🔵 OAuth Apps
- Act **on behalf of a user**
- Consume a GitHub license
- Access limited by **token scopes** + user access
- Best for apps needing user identity
- Used by tools like IDE extensions


#### 🟢 GitHub Apps
- Act as a **bot/service**, not the user
- **Do not** consume licenses
- Installed on **selected repos**
- Have **granular permissions** (read/write per-resource)
- Use **installation tokens** (expire in ~1 hour)

Best for enterprise automation.

---

### 🔍 4. Permission Differences
Apps may request access to:
- Repo contents
- PRs & issues
- Checks
- Deployments
- Members
- Metadata

You can revoke access anytime from: **Settings → Installed Apps**.

---

### 🧪 5. When to Choose What

| Scenario | Best Choice |
|----------|-------------|
| Need app to act like a user | OAuth App |
| Need minimal, repo-specific permissions | GitHub App |
| Avoid consuming licenses | GitHub App |
| Need broad access across repos | OAuth App |
| Maximum automation security | GitHub App |

🧠 Rule: Use the **least privileged option**.

---

### 🔐 6. GitHub Access Tokens
GitHub provides several token types for authentication.

#### A. Personal Access Tokens (PATs)
- Used for HTTPS Git & API
- Must be treated as passwords
- Scoped permissions
- Tied to the user account

#### B. Device Tokens
- Machine-level PAT
- Used for runners/cron jobs
- Consume a license

#### C. GitHub App Installation Tokens
- Generated automatically
- Valid for ~1 hour
- Limited to granted repos

#### D. OAuth Tokens
- Short-lived (10 min)
- Obtained via OAuth flow

#### E. Refresh Tokens
- Valid for ~6 months
- Used to renew OAuth tokens

---

### 🏷 7. Token Prefixes

| Prefix | Token Type |
|--------|------------|
| ghp_ | Personal Access Token |
| ghu_ | User-to-server token |
| ghs_ | Server-to-server token |
| gho_ | OAuth token |
| ghr_ | Refresh token |

Prefixes improve readability & secret‑scanning accuracy.

---

### 🚫 8. Token Rate Limits
- **GitHub Apps:** 15,000 requests/hour per installation
- **OAuth Apps:** 5,000 requests/hour per token

Check rate limit:
```bash
curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/rate_limit
```

If API limit is hit, use caching and batching.

---

### 🛡 9. Application Security Practices
- Add `SECURITY.md`
- Document disclosure process
- Rotate tokens frequently
- Enforce least-privilege permissions

---


# 📘 GitHub Script (actions/github-script)

### 🎯 1. What is GitHub Script?
A GitHub Action that allows running **JavaScript** directly inside workflow files.
It provides:
- A pre-authenticated **Octokit client** (`github`)
- The **workflow context** (`context`)
- Full Node.js support (fs, path, etc.)

Useful for **small automation tasks** without setting up full Node.js projects.

---

### 🧠 2. What is Octokit?
GitHub’s official REST API client.
It lets you automate:
- Issues
- Pull Requests
- Commits
- Projects
- Releases
- Users & Orgs

GitHub Script provides Octokit **ready-to-use**.

---

### 🔄 3. GitHub Script vs Manual Octokit

| Manual Octokit | GitHub Script |
|----------------|----------------|
| Need to install libraries | No installation needed |
| Need to authenticate | Automatically authenticated |
| Needs project setup | Zero setup |
| Boilerplate required | Only write logic |

---

### ⚙️ 4. Basic Workflow Example — Auto-Comment on New Issues
```yaml
name: Learning GitHub Script
on:
  issues:
    types: [opened]
jobs:
  comment:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/github-script@0.8.0
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            github.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: "🎉 You've created this issue comment using GitHub Script!!!"
            })
```

---

### 🗂 5. Adding Issues to a Project Board
```yaml
github.projects.createCard({
  column_id: {{columnID}},
  content_id: context.payload.issue.id,
  content_type: "Issue"
})
```

---

### 🧩 6. Conditional Logic in Steps
```yaml
if: contains(github.event.issue.labels.*.name, 'bug')
```
This adds conditions to workflow steps.

---

### 🖥 7. Use Node.js for Advanced Scenarios
Example: Use a file template for comments.

```yaml
- uses: actions/checkout@v2
- uses: actions/github-script@0.8.0
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    script: |
      const fs = require('fs')
      const body = fs.readFileSync(".github/ISSUE_RESPONSES/comment.md", "utf8")
      github.issues.createComment({
        issue_number: context.issue.number,
        owner: context.repo.owner,
        repo: context.repo.repo,
        body
      })
```

---

### 🧪 8. What GitHub Script Can Automate
- Issue comments
- Labeling
- Closing stale issues
- Reviewer assignment
- Updating files
- Project board automation
- Creating releases
- API reactions to GitHub events

If GitHub’s API can do it — GitHub Script can automate it.

---

## 📘 Summary — Part 3
You learned:
- Differences between GitHub Apps & OAuth Apps
- Token types, prefixes, and rate limits
- Security best practices for apps
- How GitHub Script works
- How to use Octokit inside workflows
- How to automate issue comments, project cards, conditions, and more

