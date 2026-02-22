# GitHub Notes Part 2 – Complete Detailed Notes

## 📘 GitHub Script – Automating GitHub with Workflows

### **1. What is GitHub Script?**
GitHub Script is a GitHub Action that lets you run JavaScript directly inside workflow files. It provides:
- A pre-authenticated **Octokit client (github)**
- Access to **workflow context (context)**
- Ability to run Node.js code without setup

It simplifies interacting with the GitHub API (issues, PRs, users, repos, projects, etc.).

### **2. What is Octokit?**
Octokit is GitHub's official REST API client. It lets automation scripts:
- comment on issues
- open PRs
- add cards to project boards
- access repository metadata
- manage releases

### **3. GitHub Script Workflow Example (Comment on New Issues)**
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
### **4. Add Issue to Project Board**
```yaml
github.projects.createCard({
  column_id: {{columnID}},
  content_id: context.payload.issue.id,
  content_type: "Issue"
})
```

### **5. Using Multiple Steps + Conditional Logic**
```yaml
- name: Add issue to project board
  if: contains(github.event.issue.labels.*.name, 'bug')
  uses: actions/github-script@0.8.0
```

### **6. Using Node.js Inside Workflows**
You can read files using Node.js:
```javascript
const fs = require('fs')
const issueBody = fs.readFileSync('.github/ISSUE_RESPONSES/comment.md','utf8')
```

---

## 📘 GitHub Apps, OAuth Apps & Access Tokens

### **1. OAuth Apps vs GitHub Apps**
| Feature | GitHub Apps | OAuth Apps |
|--------|-------------|------------|
| Identity | Acts as a service | Acts as a user |
| Permissions | Granular | Broad scopes |
| License | No license needed | Consumes user license |
| Installed on | Repos/Orgs | Users |
| Access | Limited to granted repos | Full user repo access |

### **2. When to Use Which**
- **Use GitHub Apps** → automation, least privilege, CI/CD bots
- **Use OAuth Apps** → apps acting exactly as user identity

### **3. Access Tokens**
| Token | Prefix | Purpose |
|--------|--------|----------|
| Personal Access Token | ghp_ | Authenticate user API requests |
| User-to-server token | ghu_ | GitHub App user auth |
| Server-to-server token | ghs_ | App installation auth |
| OAuth token | gho_ | OAuth App auth |
| Refresh token | ghr_ | Renew OAuth tokens |

### **4. Rate Limits**
- GitHub Apps: **15,000 requests/hour**
- OAuth Apps: **5,000 requests/hour**

### **5. Check Rate Limit**
```bash
curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/rate_limit
```

---

## 📘 CI with GitHub Actions

### **1. CI Workflow Template (Node.js)**
```yaml
name: Node.js CI
on:
  push:
    branches: ["main"]
  pull_request:
    branches: ["main"]
jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [14.x,16.x,18.x]
    steps:
    - uses: actions/checkout@v3
    - uses: actions/setup-node@v3
      with:
        node-version: ${{ matrix.node-version }}
    - run: npm ci
    - run: npm run build --if-present
    - run: npm test
```

### **2. Reusable Workflows**
- Reduce duplication
- Centralize CI/CD logic
- Version workflows (`@v1`)

### **3. Build Matrix Example**
```yaml
matrix:
  os: [ubuntu-latest, windows-latest]
  node-version: [16.x,18.x]
```

### **4. Separate Build and Test Jobs**
```yaml
test:
  runs-on: ${{ matrix.os }}
  steps:
    - run: npm install
    - run: npm test
```

### **5. Debugging Workflows**
Enable debug logs:
- `ACTIONS_STEP_DEBUG=true`
- `ACTIONS_RUNNER_DEBUG=true`

### **6. Artifacts Upload/Download**
```yaml
- uses: actions/upload-artifact@v2
  with:
    path: public/
```

```yaml
- uses: actions/download-artifact@v2
  with:
    path: public
```

### **7. Caching Dependencies**
```yaml
uses: actions/cache@v2
with:
  path: ~/.npm
  key: ${{ runner.os }}-npm-${{ hashFiles('**/package-lock.json') }}
```

---

## 📘 Release‑Based Workflow

### **1. Project Boards**
Used to plan releases with columns:
- To do
- In progress
- Done

### **2. Milestones**
Track issues/PRs tied to a specific version.

### **3. Branching Strategy**
Long‑lived branches:
```
release-v1.0
release-v2.0
```
These branches:
- are protected
- serve different customer versions

### **4. Cherry‑Pick for Backporting**
```bash
git cherry-pick <sha>
```

### **5. Creating Releases**
Include:
- Git tag (e.g., v1.2.0)
- Release notes
- Attach binaries
- Mark prerelease if needed

Use **Release Drafter** to automate notes.

---

## 📘 Continuous Delivery (CD) with GitHub Actions

### **1. Trigger CD Using PR Labels**
```yaml
on:
  pull_request:
    types: [labeled]
```

Example conditional:
```yaml
if: contains(github.event.pull_request.labels.*.name, 'stage')
```

### **2. Storing Azure Credentials in GitHub Secrets**
```yaml
creds: ${{ secrets.AZURE_CREDENTIALS }}
```

### **3. Deploy Container to Azure Web Apps**
```yaml
- name: Login via Azure CLI
  uses: azure/login@v1
  with:
    creds: ${{ secrets.AZURE_CREDENTIALS }}

- uses: azure/docker-login@v1

- uses: azure/webapps-deploy@v1
  with:
    app-name: ${{ env.AZURE_WEBAPP_NAME }}
    images: registry/repo/image:${{ github.sha }}
```

### **4. Create & Destroy Azure Resources via Workflow**
Use Azure CLI:
```yaml
az group create --location ...
az appservice plan create ...
az webapp create ...
```

Use labels:
```yaml
if: contains(github.event.pull_request.labels.*.name, 'spin up environment')
```

### **5. Delete Artifacts Early**
```yaml
retention-days: 10
```

### **6. Status Badges**
```markdown
![status](https://github.com/user/repo/actions/workflows/ci.yml/badge.svg)
```

### **7. Environment Protections**
- Required reviewers
- Wait timers
- Branch/tag restrictions

Example:
```yaml
environment: production
```

---

# END OF PART 2 NOTES
