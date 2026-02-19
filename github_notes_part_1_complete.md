# GitHub Notes Part 1 – Complete Detailed Version

## 📘 GitHub – Introduction & Core Concepts

### **1. What GitHub Is**
GitHub is a **cloud platform built on Git**, the underlying version-control engine.
Git = engine (tracks code changes)
GitHub = car (UI + collaboration + automation)

Real‑world analogy → *Google Docs for code* but with full history + reviews.

---

### **2. Core Pillars of GitHub Enterprise**

#### **a. AI Tools**
- GitHub Copilot
- Copilot Chat
- AI-assisted PR reviews
- AI-guided security scanning

#### **b. Collaboration Tools**
- Repositories
- Issues
- Pull Requests
- Discussions

#### **c. Productivity**
- Built‑in CI/CD
- Automation workflows (GitHub Actions)

#### **d. Security**
- CodeQL
- Dependabot
- Secret scanning

#### **e. Scale**
- 100M+ developers
- 420M+ repositories

---

## **3. Repositories**
A repository is a **project folder** that stores:
- code files
- commit history
- branches
- issues
- pull requests

### **Create a repository**
1. Click `+` → **New Repository**
2. Add name & description
3. Select public/private
4. Click **Create**

### **Clone a repository**
```bash
git clone <repository-url>
cd <repository-name>
```

---

## **4. Adding Files**
Ways to add files:
- Create new file on GitHub
- Upload file
- Add + commit locally

Commit example:
```bash
git add .
git commit -m "Added config file"
```

---

## **5. Gists**
Mini-repositories for:
- code snippets
- notes
- config examples

Types:
- Public
- Secret

⚠️ Never store passwords or API keys.

---

## **6. Wikis**
Used for long documentation like:
- setup guides
- architecture docs
- manuals

---

## **7. Feature Previews**
Try experimental GitHub features: **Profile → Feature Preview**.

---

# 🔄 GitHub Flow – Core Concepts

## **1. Branches**
A branch is a *safe workspace* to make changes.

Analogy → Main = production kitchen; Branch = test kitchen.

## **2. Commits**
Each commit includes:
- ID
- author
- timestamp
- message

File states:
- Untracked
- Modified
- Staged
- Committed

## **3. Pull Requests**
A PR is used for:
- code review
- discussion
- suggestions
- merge requests

### GitHub Flow Diagram
```
Create Branch → Make Commits → Open PR → Review → Merge → Delete Branch
```

---

# 🧩 Issues & Discussions

## **Issues**
Used for:
- bugs
- tasks
- ideas
- feature requests

## **Discussions**
Used for:
- questions
- polls
- announcements
- brainstorming

---

# 🔔 Notifications
Notification options:
- Watching
- Not watching
- Ignore
- Custom

Search mentions:
```
mentions:<username>
```

---

# 🌐 GitHub Pages
Host websites directly from your repo.
Supports:
- HTML
- CSS
- JS
- Jekyll optional

---

# 📘 Migrating an Existing Project to GitHub

## **1. Why migrate?**
- Better branching
- Cloud access
- Collaboration tools
- Automation + CI/CD

## **2. Planning Migration**
Choose between:
- keeping only current source
- keeping full history via GitHub Migrator

Non-code items (issues/PRs) may need separate tools.

---

## **3. Handling Binary Files**
Use **Git LFS** for:
- large media
- binaries
- zip files

Avoid storing large binaries directly.

---

## **4. Important Git Files**

### `.gitignore`
Example:
```
[Bb]in/
```

### `README.md`
Project overview.

### `LICENSE.md`
Legal usage.

### `CONTRIBUTING.md`
Contribution rules.

### `SECURITY.md`
How to report security issues.

---

## **5. Importing Your Project**
Steps:
1. New Repo → Import Code
2. Add old repo URL
3. Choose visibility
4. Fix large file issues

---

# 📘 Uploading a New Project

## **Using GitHub Importer**
Importers support SVN, Mercurial, TFVC, Git.

Capabilities:
- authentication
- author mapping
- LFS migration

---

## **Using Command Line**

### Create empty repo
```bash
git init -b main
git add .
git commit -m "initial commit"
```

### Add remote & push
```bash
git remote add origin <REMOTE_URL>
git push origin main
```

---

## **Using GitHub CLI**
```bash
gh repo create --source=. --public --push
```

---

# 📘 Pull Request Statuses & Merging

## **PR Statuses**
- Draft → not ready
- Open → active
- Closed → abandoned
- Merged → successfully merged

## **Merge Methods**

### Merge Commit
Preserves history.

### Squash Merge
Combines all into one commit.

### Rebase Merge
Linear history.

---

# 📘 Merge Conflicts

### Why conflicts happen
- same lines changed in two branches

### Conflict markers
```bash
<<<<<<< HEAD
your version
=======
main version
>>>>>>> main
```

### Best practices
```bash
git pull
git pull --rebase
```

---

# 📘 Searching & Organizing History

## **Search types**
### Global search
### Context search (Issues/PRs tabs)

## **Useful filters**
```bash
is:open is:issue assignee:@me
is:pr sidebar in:comments
is:open is:issue label:bug -linked:pr
```

## **Milestones**
Used for releases, sprints.

## **Labels**
Categorize issues/PRs.

## **Git Blame**
Shows:
- who edited a line
- when
- which commit

## **Cross-linking**
- `#123` links to issue 123
- commit hash auto-links

## **Saved Replies**
Prebuilt responses.

## **Issue Templates**
Structured forms.

## **Assignees**
Assign responsibility.

## **@mentions**
Notifies users.

---

# 📘 InnerSource – Open Source Inside a Company

## **1. What is InnerSource?**
Open-source development patterns used internally.

## **2. Benefits**
- visibility
- reduced friction
- standardization

## **3. Repository Visibility**
- Public
- Internal (best for InnerSource)
- Private

## **4. Permission Levels**
- Read
- Triage
- Write
- Maintain
- Admin

## **5. Create Discoverable Repos**
- good names
- description
- license
- README

## **6. README Best Practices**
Include:
- vision
- setup steps
- screenshots
- dependencies

## **7. CONTRIBUTING.md & CODEOWNERS**
Rules for contribution & ownership.

## **8. Templates**
- issue templates
- PR templates

## **9. Workflows**
Define branching & PR rules.

## **10. Metrics to Track**
- contributors
- PR size
- review speed
- cross-team usage

---

# END OF NOTES
