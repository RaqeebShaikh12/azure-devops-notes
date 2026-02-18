
# GitHub Repository Security – Simplified Notes

## 1. Introduction – Why Secure Your GitHub Repo?
Security must be applied throughout the software development lifecycle. A vulnerable repository can expose passwords, credentials, private code, and customer data. GitHub provides built‑in automated tools that allow administrators to secure repositories without slowing down developers.

---

## 2. Why Secure Development Strategy Matters
Modern applications must be secure from the ground up.
- Developers may assume they understand security, but threats evolve constantly, so continuous training is needed.
- Code must be securely written and reviewed to prevent bugs and vulnerabilities.
- Regulations (GDPR, HIPAA, PCI) require compliant code and processes.

**Shifting left** means moving security earlier in the development lifecycle so issues are caught sooner, reducing rework and preventing late‑stage problems.

---

## 3. GitHub Security Tab Features
GitHub provides several features to help secure repositories:

### **A. SECURITY.md**
A file added to the repo to explain how contributors should responsibly report vulnerabilities.

### **B. Dependabot Alerts**
Automatically detects vulnerable dependencies in your project and alerts maintainers.

### **C. Security Advisories**
Allows maintainers to privately discuss, fix, and publish details about vulnerabilities.

### **D. Code Scanning (CodeQL)**
Automatically scans code to detect vulnerabilities and unsafe patterns.

### **E. Secret Scanning**
Detects committed API keys, secrets, and credentials. Public repos have push protection enabled by default.

---

## 4. Keeping Sensitive Files Out Using `.gitignore`
`.gitignore` prevents developers from accidentally committing unwanted or sensitive files. It can exclude:
- Build output
- Config files
- Credentials
- Logs
- Temporary files

### Example:
```gitignore
*.suo
mono_crash.*
[Dd]ebug/
[Rr]elease/
/config
/Web/TypeScript/**/*.js
```

**Note:** If sensitive data is ever committed, assume it’s compromised. Removing it requires special Git cleanup procedures.

---

## 5. Branch Protection Rules
Help ensure that important branches (like `main`) remain safe.
You can enforce:
- Required pull‑request reviews
- Passing CI tests
- Block force pushes
- Prevent deleting branches
- Require up‑to‑date branches

This ensures only reviewed, safe code is merged.

---

## 6. Required Pull‑Request Reviewers
Require that code changes must be reviewed by others before merging. This improves:
- Code quality
- Security
- Accountability

You can enforce:
- Review from CODEOWNERS
- Fresh review if new commits are added
- Approval from someone other than the last developer who pushed code

---

## 7. CODEOWNERS File
Automatically assigns reviewers to specific files or directories.

### Example:
```
*.js    @js-owner
/build/ @octocat
```
Changes to these files will automatically require review from the assigned owners.

---

## 8. Automated Dependency Security
Modern apps rely heavily on external packages.

### **Dependency Graph**
GitHub automatically creates a graph showing all dependencies and sub‑dependencies.

### **Dependabot Alerts**
Alerts maintainers when a dependency has a known vulnerability.

### **Dependabot Security Updates**
Automatically creates pull requests to update vulnerable packages.

---

## 9. Automated Code Scanning
GitHub can scan your code using CodeQL to detect:
- Security vulnerabilities
- Dangerous coding patterns
- Common mistakes

Code scanning helps prevent developers from introducing new vulnerabilities.

---

## 10. Secret Scanning
GitHub scans repositories for known secret patterns such as:
- API keys
- Cloud provider tokens
- Passwords
- Database connection strings

If detected:
- GitHub notifies the secret provider
- Provider may revoke or rotate the secret

Push protection blocks commits containing secrets (public repos only).

---

## 11. Summary
You learned:
- Why securing your GitHub repository is essential
- How to use `.gitignore` to avoid leaking sensitive data
- How to enforce protection via branch rules and reviews
- How to automate security using Dependabot, CodeQL, and secret scanning

These tools collectively reduce risk and help maintain a secure, well‑managed repository.

