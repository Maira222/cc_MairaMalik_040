# Lab 2 - Git & GitHub Practice

**Name:** Maira Malik  
**Reg. No:** 2023-BSE-040  
**Subject:** Cloud Computing  

---

## 📌 Tasks

### Task 1: Create Private GitHub Repository
- Create a new private repository named **Lab2** on GitHub.

---

### Task 2: Connect Repository via SSH
1. Generate a new SSH key:
   ```bash
   ssh-keygen -t ed25519 -C "your_email@example.com"
   ```
2. Add your SSH public key to GitHub (**Settings > SSH and GPG keys**).
3. Clone the repository using SSH:
   ```bash
   git clone git@github.com:<yourusername>/Lab2.git
   ```

---

### Task 3: Configure Git Username and Email
```bash
git config --global user.name "Your Name"
git config --global user.email "your_email@example.com"
git config --list
```

---

### Task 4: Explore the `.git` Folder
```bash
ls -a .git
```

---

### Task 5: Local Repository Management
```bash
rm -rf .git          # Delete existing .git
git init             # Re-initialize git
echo "# Lab2 Git Practice" > README.md
git add README.md
git commit -m "Initial commit"
git remote add origin git@github.com:<yourusername>/Lab2.git
git push -u origin main
```

---

### Task 6: File Status & Staging
```bash
echo "My first note" > notes.txt
git status
git add notes.txt
git commit -m "Add notes.txt"
```

---

### Task 7: Branch Creation (GitHub GUI)
- Create a branch **bugfix/user-auth-error** using GitHub UI.  
- Pull it locally:
  ```bash
  git pull origin bugfix/user-auth-error
  ```

---

### Task 8: Branch Creation (Git Bash)
```bash
git checkout -b feature/db-connection
git push origin feature/db-connection
```

---

### Task 9: Branching & Merging
```bash
git checkout -b feature-1
# modify main.py
git add main.py
git commit -m "Add new function to main.py"
git checkout main
git merge feature-1
git push origin main
git push origin feature-1
```

---

### Task 10: Pull Request & Branch Review
- Create PR on GitHub from **feature/db-connection → main**.  
- Review & merge using GUI.  
- Delete merged branch.

---

### Task 11: Professional Branching Strategy
Branches to create:
- `develop`
- `staging`
- `feature/*`
- `bugfix/*`

**Workflow:**
- Work on `feature/*` or `bugfix/*`
- Merge into `develop`
- Merge `develop` into `staging`
- Merge `staging` into `main`

---

### Task 12: Code Review Workflow
1. Create a Pull Request from feature → main.  
2. Add clear title and description.  
3. Assign reviewer.  
4. Reviewer approves & merges.

---

### Task 13: Branch Cleanup Best Practices
```bash
# After merge, update local repo
git checkout main
git pull origin main
git branch -d <branch-name>
git branch
```

---

## 📝 Exam Evaluation Questions

### Q1: Advanced Branching & Merge Verification
- Create a branch, make changes, merge into main.  
- Show commit history with merge.

### Q2: Multi-Stage Workflow Simulation
- Setup branches: main, develop, staging.  
- Workflow: feature → develop → staging → main.  
- Provide proof at each stage.

### Q3: Collaboration & Conflict Resolution
- Two contributors edit same file in different branches.  
- Merge to cause conflict.  
- Resolve so both changes remain.  
- Show final version with both contributions.

---

✅ **This README documents all Git & GitHub tasks for Lab 2.**

