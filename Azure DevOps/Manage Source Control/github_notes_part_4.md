# GitHub Notes – Part 4 (CI, CD & Release‑Based Workflow)

## 📘 Continuous Integration (CI) with GitHub Actions

### 🚀 1. What is Continuous Integration (CI)?
CI automates building and testing code whenever changes are pushed.
Benefits:
- Catch bugs early
- Stable main branch
- Faster releases
- Team-wide consistency

Workflows live in:
```
.github/workflows/*.yml
```

---

### 🧰 2. Creating Workflows
A workflow contains:
- **Triggers** (`on:`)
- **Jobs** (one or many)
- **Steps** inside each job
- **runs-on** (OS)
- **env / if / permissions`**

---

### 📦 3. Node.js CI Template
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
          cache: npm
      - run: npm ci
      - run: npm run build --if-present
      - run: npm test
```

---

### 🔁 4. Reusable Workflows
Key benefits:
- Reduce duplication
- Centralized CI logic
- Versioned (ex: `@v1`)
- Ideal for large orgs

---

### 🧪 5. Matrix Testing
Test combinations of OS + versions:
```yaml
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest]
    node-version: [16.x, 18.x]
```
Produces 4 pipelines.

---

### 🔎 6. Separate Build & Test Jobs
```yaml
test:
  runs-on: ${{ matrix.os }}
  strategy:
    matrix:
      os: [ubuntu-latest, windows-latest]
      node-version: [16.x,18.x]
  steps:
    - uses: actions/checkout@v3
    - uses: actions/setup-node@v3
      with:
        node-version: ${{ matrix.node-version }}
    - run: |
        npm install
        npm test
      env:
        CI: true
```

---

### 🛠 7. Managing & Debugging Workflows
Trigger debugging:
```yaml
run: echo "Triggered by ${{ github.event_name }}"
```
Enable debug logs:
- `ACTIONS_STEP_DEBUG=true`
- `ACTIONS_RUNNER_DEBUG=true`

---

### 📦 8. Artifacts (Upload/Download)
Upload:
```yaml
- uses: actions/upload-artifact@main
  with:
    name: webpack artifacts
    path: public/
```
Download:
```yaml
- uses: actions/download-artifact@main
  with:
    name: webpack artifacts
    path: public
```
Retention default = 90 days, override via:
```yaml
retention-days: 10
```

---

### 🧰 9. Caching
```yaml
uses: actions/cache@v2
with:
  path: ~/.npm
  key: ${{ runner.os }}-npm-${{ hashFiles('**/package-lock.json') }}
```

---

### 🏷 10. Labels After Approval
```yaml
- name: Label when approved
  uses: pullreminders/label-when-approved-action@main
  env:
    APPROVALS: "1"
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    ADD_LABEL: "approved"
```

---

## 📘 Continuous Delivery (CD) with GitHub Actions

### 🚀 1. Trigger CD With Labels
```yaml
on:
  pull_request:
    types: [labeled]
```
Run only if PR has label:
```yaml
if: contains(github.event.pull_request.labels.*.name, 'stage')
```

---

### 🔐 2. GitHub Secrets for Credentials
Store Azure credentials safely:
```yaml
creds: ${{ secrets.AZURE_CREDENTIALS }}
```

---

### ☁️ 3. Deploy to Azure Web Apps (Container)
```yaml
Deploy-to-Azure:
  runs-on: ubuntu-latest
  needs: Build-Docker-Image
  steps:
    - name: Login via Azure CLI
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}

    - uses: azure/docker-login@v1
      with:
        login-server: ${{env.IMAGE_REGISTRY_URL}}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}

    - name: Deploy web app container
      uses: azure/webapps-deploy@v1
      with:
        app-name: ${{env.AZURE_WEBAPP_NAME}}
        images: ${{env.IMAGE_REGISTRY_URL}}/${{ github.repository }}/${{env.DOCKER_IMAGE_NAME}}:${{ github.sha }}

    - name: Azure logout
      run: az logout
```

---

### 🛠 4. Create & Destroy Azure Resources (IaC)
```yaml
jobs:
  set-up-azure-resources:
    if: contains(github.event.pull_request.labels.*.name, 'spin up environment')

  destroy-azure-resources:
    if: contains(github.event.pull_request.labels.*.name, 'destroy environment')
```
Azure CLI example:
```yaml
- run: |
    az group create --location ${{env.AZURE_LOCATION}} --name ${{env.AZURE_RESOURCE_GROUP}}
    az appservice plan create --resource-group ${{env.AZURE_RESOURCE_GROUP}} --name ${{env.AZURE_APP_PLAN}} --is-linux --sku F1
    az webapp create --resource-group ${{ env.AZURE_RESOURCE_GROUP }} --plan ${{ env.AZURE_APP_PLAN }} --name ${{ env.AZURE_WEBAPP_NAME }} --deployment-container-image-name nginx
```

---

### 🧹 5. Cleanup & Status Badges
Badges:
```markdown
![Build Status](https://github.com/user/repo/actions/workflows/ci.yml/badge.svg?branch=my-workflow)
```

---

### 🛡 6. Environment Protections
- Required reviewers
- Wait timers
- Branch/tag restrictions
- Custom rules via GitHub Apps

Example:
```yaml
environment: production
```

---

## 📘 Release‑Based Workflow

### 🗂 1. Project Boards
Track release work using:
- To do
- In progress
- Done

Cards = Issues / PRs / Notes.

---

### 🎯 2. Milestones
Organize issues/PRs by product version.

---

### 🌿 3. Branching Strategy
Long‑lived release branches:
```
release-v1.0
release-v2.0
release-v3.0
```
Mark them **protected**.

---

### 🔄 4. Cherry‑Pick For Backport Fixes
```bash
git cherry-pick <sha>
```

---

### 📦 5. Creating Releases on GitHub
Includes:
- Git tag (ex: v1.2.0)
- Release name
- Notes
- Attach binaries
- Mark prerelease if needed

**Release Drafter** automates notes.

---

## 📘 Summary — Part 4
You learned:
- CI workflows, matrices, artifacts, caching
- How to debug workflows
- How to trigger CD deployments
- How to deploy containers to Azure
- How to automate resource creation & cleanup
- How to use environment protections
- How to create & manage Release‑based workflows

