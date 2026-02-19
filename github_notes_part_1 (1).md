
# GitHub Notes Part 1

## Introduction to GitHub
GitHub is a cloud-based platform built on top of Git, a distributed version control system. GitHub enhances collaboration with features like branches, pull requests, issues, discussions, AI-assisted development (Copilot), and automation through CI/CD. It also provides strong security tools like Dependabot, CodeQL, and secret scanning.

### Key Concepts
- **Git**: Tracks changes, supports branching, merging, and collaboration.
- **GitHub**: Adds UI, automation, security, AI, and collaboration features around Git.
- **Repositories**: Project containers storing files, history, issues, PRs, and more.
- **GitHub Flow**: Lightweight workflow using branches → commits → pull requests → merge.

---

## Migrating Existing Projects
When moving from legacy systems (SVN, Mercurial, TFVC), consider:

### Why migrate?
- GitHub offers modern collaboration, cloud access, security, and automation.
- Git provides powerful branching, merging, and version history.

### Migration Steps
1. Decide whether to keep old version history.
2. Prepare `.gitignore`, clean binaries, and remove sensitive files.
3. Use **GitHub Importer**, CLI, or external tools.
4. Handle large files using Git LFS.
5. After import, update commit author attributions.

---

## Uploading a New Project
If your code is local or not in any VCS:

### Options to upload
- **GitHub Importer** (via browser)
- **GitHub CLI** (`gh repo create`)
- **Git commands** (`git init`, `git add`, `git commit`, `git push`)

### Using GitHub CLI
```
git init -b main
git add .
git commit -m "initial commit"
gh repo create --source=. --public --push
```

### Using Git
```
git init -b main
git add .
git commit -m "First commit"
git remote add origin <REMOTE_URL>
git push origin main
```

---

## Pull Requests & Merge Options
A pull request (PR) proposes merging changes from one branch into another.

### PR Status Types
- **Draft**: Not ready for review; cannot merge.
- **Open**: Active PR; ready for review; more commits allowed.
- **Closed**: PR closed without merging.
- **Merged**: Changes successfully merged.

### Merge Methods
- **Merge Commit**: Preserves full commit history.
- **Squash and Merge**: Combines all commits into one.
- **Rebase and Merge**: Linear history without merge commit.

### Branch Protection Rules
- Required reviews
- CI checks must pass
- No unresolved comments

---

## Merge Conflicts
Merge conflicts occur when two branches modify the same lines.

### Why they happen
- Branch diverged from main
- Overlapping code edits

### Conflict Markers
```
<<<<<<< HEAD
your changes
=======
main branch changes
>>>>>>> main
```

### Best Practices
- Pull often (`git pull`)
- Rebase before merge (`git rebase main`)
- Resolve conflicts using GitHub or IDE tools

---

## Searching & Organizing History
GitHub provides powerful search and organizational tools.

### Search Types
- **Global Search**: Searches all GitHub.
- **Context Search** (Issues/PR tabs): Scoped to repository.

### Useful Filters
```
is:open is:issue assignee:@me
is:pr label:bug
milestone:"Release v1.0"
```

### Labels
Categorize issues/PRs (e.g., bug, enhancement, documentation).

### Milestones
Group issues/PRs by release or sprint.

### Git Blame
Shows who last modified each line.

### Cross-linking
- `#8` auto-links issue 8.
- Commit hashes auto-link when pasted.

### Saved Replies
Pre-written responses for repetitive communication.

### Issue Templates vs Saved Replies
- **Templates**: Capture structured info when creating issues/PRs.
- **Saved replies**: For repeated responses after issue creation.

### Assignees
Tracks responsibility on issues/PRs.

---

## InnerSource
InnerSource applies open-source practices inside a private company.

### Benefits
- Visibility across teams
- Reduced friction for dependencies
- Standardization of workflows

### Repository Visibility
- **Public**: Everyone
- **Internal**: Enterprise-only (best for InnerSource)
- **Private**: Restricted contributors

### Permission Levels
- Read, Triage, Write, Maintain, Admin

### Making Repos Discoverable
- Clear naming
- Descriptions
- License file
- Strong README

### README Best Practices
- Purpose and vision
- Setup instructions
- Dependencies
- Screenshots/examples
- Demo links

### CONTRIBUTING.md
Defines contribution rules and expectations.

### CODEOWNERS
Defines required reviewers.

### Templates
- `.github/ISSUE_TEMPLATE.md`
- `.github/PULL_REQUEST_TEMPLATE.md`

### Workflow Definition
- branching strategy
- PR rules
- release workflow

### Measuring InnerSource Success
Metrics should focus on **process**, not individuals:
- PR size
- review turnaround time
- unique contributors
- code reuse
- cross-team @mentions

