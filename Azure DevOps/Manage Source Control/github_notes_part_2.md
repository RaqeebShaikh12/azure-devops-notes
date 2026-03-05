# GitHub Notes – Part 2 (Markdown & Security)

## 📘 Markdown – Core Concepts & GitHub‑Flavored Markdown (GFM)

### 1) What Markdown Is
Markdown is a **lightweight markup language** for formatting text without HTML complexity. It’s readable as plain text and widely supported across GitHub, editors, and tools.

---

### Emphasis
```markdown
This is *italic* text.
This is _italic_ text.

This is **bold** text.
This is __bold__ text.

_This is **italic and bold** text_
__This is *bold and italic* text__

\*This shows a literal asterisk\*
```

### Headings
```markdown
# H1
## H2
### H3
###### H6
```

### Images & Links
```markdown
![Alt text](/path/image.png)
[Microsoft Training](/training)
```

### Lists
```markdown
1. First
1. Second
1. Third

- First
  - Nested item
- Second
```

### Tables
```markdown
First | Second
----- | ------
1     | 2
3     | 4
```

### Blockquotes
```markdown
> This is quoted text.
```

### Inline HTML
```markdown
Here is a<br/>line break
```

### Code
```markdown
This is `inline code`.
```

Fenced blocks:
````markdown
```
var a = 1;
var b = 2;
var sum = a + b;
```
````

With highlighting:
```javascript
var first = 1;
var second = 2;
var sum = first + second;
```

### Cross‑linking Issues & PRs
```text
#3602
GH-3602
desktop/desktop#3602
```

### Linking Commits
```text
8304e9c271a5… → 8304e9c
user@SHA
repo/repo@SHA
```

### Mentions & Tasks
```markdown
@githubteacher

- [x] Completed task
- [ ] Pending task
```

### Slash Commands (examples)
- `/code` (insert code block)
- `/details` (collapsible)
- `/table` (quick table)
- `/tasklist` (issue task list)
- `/template` (insert issue/PR template)

---

## 🔐 Maintaining a Secure GitHub Repository

### 1) Why Security Matters
Bake security into every stage (shift‑left): prevent data leaks, ensure correct permissions, secure coding, and meet compliance.

### 2) Security features (Security tab)
- `SECURITY.md` (how to report vulnerabilities)
- Dependabot alerts
- Security Advisories (private coordination → publish CVE)
- Code scanning (CodeQL)
- Secret scanning (public repos default ON; enable for private)

### 3) SECURITY.md (example)
```markdown
# Security Policy
Please report vulnerabilities at security@example.com.
```

### 4) .gitignore (avoid sensitive/irrelevant files)
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

### 5) Removing sensitive data
Assume anything ever committed is compromised. Use GitHub’s guide to **scrub history** (do not just overwrite a commit).

### 6) Branch protection rules
- Required reviews
- Required status checks
- Code owner approvals

### 7) Required reviewers options
- Require CODEOWNERS approval
- Dismiss stale approvals on new commits

### 8) CODEOWNERS (example)
```
*.js     @js-team
/build/  @octocat
```

### 9) Automated Security
- **Dependency Graphs** (detects manifests)
- **Dependabot Alerts** (known vulnerabilities)
- **Dependabot Updates** (auto‑PRs to bump versions)
- **Code Scanning (CodeQL)** (Find → Triage → Fix)
- **Secret Scanning** (detect tokens/keys)
