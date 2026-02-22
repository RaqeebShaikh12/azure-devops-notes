# GitHub Notes Part 2 – Markdown & Security (Complete Detailed Notes)

## 📘 Markdown – Core Concepts & GitHub-Flavored Markdown (GFM)

### **1. What Markdown Is**
Markdown is a **lightweight markup language** used to format text without the complexity of HTML. It provides:
- simple syntax
- clean readability
- broad support across GitHub, editors, and tools

Markdown acts as a middle ground between **plain text** and full **HTML formatting**.

---

## ✏️ Emphasizing Text

### *Italic Text*
Use `*` or `_`:
```markdown
This is *italic* text.
This is _italic_ text.
```

### **Bold Text**
Use `**` or `__`:
```markdown
This is **bold** text.
This is __bold__ text.
```

### ***Bold + Italic***
```markdown
_This is **italic and bold** text_
__This is *bold and italic* text__
```

### Escaping characters
```markdown
\*This will show a literal asterisk\*
```

---

## 🏷 Headings
Use `#` symbols (# to ######):
```markdown
# H1
## H2
### H3
###### H6
```

---

## 🖼 Images & 🔗 Links
### Images
```markdown
![Alt text](/path/image.png)
```

### Links
```markdown
[Microsoft Training](/training)
```

---

## 📋 Lists
### Ordered List
```markdown
1. First
1. Second
1. Third
```

### Unordered List
```markdown
- First
  - Nested item
- Second
```

---

## 📊 Tables
```markdown
First | Second
----- | ------
1     | 2
3     | 4
```

---

## 💬 Blockquotes
```markdown
> This is quoted text.
```

---

## 🔤 Inline HTML
```markdown
Here is a<br/>line break
```

---

## 💻 Code Formatting
### Inline Code
```markdown
This is `inline code`.
```

### Code Block (fenced)
```markdown
```
var a = 1;
var b = 2;
var sum = a + b;
```
```

### Syntax Highlighting
```javascript
var first = 1;
var second = 2;
var sum = first + second;
```

---

## 🔗 Cross-linking Issues & PRs
GitHub auto-links:
```text
#3602
GH-3602
desktop/desktop#3602
```

---

## 🔗 Linking Commits
```text
8304e9c271a5…  → 8304e9c
user@SHA
repo/repo@SHA
```

---

## 👥 Mentioning Users
```markdown
@githubteacher
```

---

## ☑️ Task Lists
```markdown
- [x] Completed task
- [ ] Pending task
```

---

## ⧉ Slash Commands
| Command | Description |
|---------|-------------|
| /code | Inserts code block |
| /details | Collapsible section |
| /table | Create Markdown table |
| /tasklist | Insert task list |
| /template | Insert issue/PR template |

---

# 🔐 Maintaining a Secure GitHub Repository

## **1. Why Security Matters**
Security must exist at **every stage** of development:
- preventing data leaks
- ensuring correct permissions
- secure coding
- compliance with regulations

**Shifting left** → moving security checks earlier in the process.

---

## 🛡 GitHub Security Features (Security Tab)
From the **Security** tab, you can enable:
- **SECURITY.md policy**
- **Dependabot alerts**
- **Security advisories**
- **Code scanning (CodeQL)**
- **Secret scanning**

---

## 📄 SECURITY.md
This file defines how users should **report vulnerabilities**.
```markdown
# Security Policy
Please report vulnerabilities at security@example.com.
```

---

## 📝 Security Advisories
Used to:
- privately discuss vulnerabilities
- fix issues internally
- publish CVE-based security notices

---

## 🗂 Using .gitignore to Protect Sensitive Files
Example `.gitignore`:
```gitignore
*.suo
mono_crash.*
[Dd]ebug/
[Rr]elease/
x64/
x86/
/config
/Web/TypeScript/**/*.js
```

---

## ❌ Removing Sensitive Data
Once committed, data is considered **compromised**.
Even deleting a commit doesn't fully remove it.
Use GitHub’s official guide to scrub history.

---

## 🔐 Branch Protection Rules
You can enforce:
- required reviews
- required status checks
- code owner approvals

---

## 👀 Required Reviewers
Settings → Branches → Add Rule
- Require PR reviews before merging
- Require CODEOWNERS approval
- Dismiss stale approvals

---

## 🧑‍🏫 CODEOWNERS Example
```
*.js     @js-team
/build/  @octocat
```

---

# 🤖 Automated Security

## 📊 Dependency Graphs
GitHub automatically scans dependency files like:
- package.json
- requirements.txt

---

## 🚨 Dependabot Alerts
Alerts when:
- vulnerabilities exist
- malware versions used

---

## 🤖 Dependabot Security Updates
Dependabot creates **PRs automatically** to update vulnerable dependencies.

---

## 🔍 Automated Code Scanning
Uses **CodeQL** to detect vulnerabilities.
```text
Find → Triage → Fix
```

---

## 🔑 Secret Scanning
Detects API keys & credentials.
Public repos → enabled by default.
Private repos → admin must enable.

---

# END OF NOTES
