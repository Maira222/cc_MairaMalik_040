**Cloud Computing - Lab #3: Advanced Git Operations**
**Name: Maira Malik** 
**Registration No.: 2023-BSE-040** 
**Subject: Cloud Computing**

This lab covers various advanced Git concepts, including managing conflicts, file tracking, resetting history, and setting up development environments.

**Task 1: Handling Local and Remote Commit Conflicts (Pull vs Pull --rebase)**
This task demonstrated conflict resolution when local and remote changes exist, comparing standard merge with rebase.

1. Initial Local Commit and Remote Push Rejection
A local change was made and committed. The push was rejected because the remote contained work not present locally, creating a conflict scenario.

Bash

$ git commit -m "Local update to readme"
# [main 354ca58] Local update to readme
$ git push origin main
# ! [rejected] main -> main (fetch first)
# hint: Updates were rejected because the remote contains work that you do not have locally.
2. Using git pull --no-rebase (Standard Merge)
The standard pull command was used, which resulted in an automatic fast-forward merge as the changes were not conflicting.

Bash

$ git pull --no-rebase origin main
# Updating 354ca58..340fa43
# Fast-forward
# 1 file changed, 1 insertion (+), 1 deletion(-)
$ git push -u origin main
# Everything up-to-date
3. Using git pull --rebase (Content Conflict Scenario)
After a new remote change, a subsequent pull --rebase was executed, resulting in a content conflict that required manual resolution.

Bash

$ git pull --rebase origin main
# Auto-merging README.md
# CONFLICT (content): Merge conflict in README.md
# error: could not apply cffbf2f... edit
# hint: Resolve all conflicts manually... then run "git rebase --continue".

**Task 2: Creating and Resolving Merge Conflicts Manually (git rebase --continue)**
This task focused on intentionally creating a content conflict and resolving it during a rebase operation.

1. Conflict Creation and Trigger
Local conflicting edits were committed. An attempt to push failed, and initiating git pull --rebase triggered the conflict.

Bash

$ git commit -m "local conflicting edit"
# [main 43549e1] local conflicting edit
$ git pull --rebase origin main
# Auto-merging README.md
# CONFLICT (content): Merge conflict in README.md
# hint: Resolve all conflicts manually... then run "git rebase --continue".
2. Manual Resolution and Continue
The conflict markers were manually edited and removed in README.md. The resolved file was staged, and the rebase was continued and pushed.

Bash

$ nano README.md # Manual resolution
$ git add README.md
$ git rebase --continue
# Successfully rebased and updated refs/heads/main.
$ git push -u origin main

**Task 3: Managing Ignored Files (.gitignore and git rm --cached)**
This task demonstrated how to ignore files that were previously tracked and remove them from the index while keeping them locally.

1. Tracking and Committing Files
A textfiles directory with three files was created, added, committed, and pushed.

Bash

$ mkdir textfiles
$ echo "File A content" > textfiles/a.txt
$ git add .
$ git commit -m "added fils to directory with 3 files"
# ... create mode 100644 textfiles/a.txt ...
$ git push origin main
2. Adding .gitignore
A .gitignore file was created to ignore the textfiles/ directory and was committed.

Bash

$ echo "textfiles/ " > .gitignore
$ git add .gitignore
$ git commit -m "added .gitignore to ignore"
3. Removing Tracked Files (--cached)
The textfiles directory was removed from Git's tracking index (remote tracking history and staging area) using git rm -r --cached, while the files were preserved in the local working directory.

Bash

$ git rm -r --cached textfiles
# rm 'textfiles/a.txt'
# rm 'textfiles/b.txt'
# rm 'textfiles/c.txt'
$ git commit -m "removes files"
# delete mode 100644 textfiles/a.txt ...
$ git push origin main

**Task 4: Create Temporary Changes and Use git stash**
This task demonstrated using git stash to save uncommitted changes temporarily before switching branches.

1. Stashing Changes to Allow Branch Switch
An attempt to switch branches failed due to uncommitted changes. git stash was used to save the changes, allowing the switch to succeed.

Bash

$ git checkout feature-branch
# error: Your local changes... would be overwritten by checkout: README.md
# Please commit your changes or stash them before you switch branches.
# Aborting
$ git stash
# Saved working directory and index state WIP on main: f3a5f6c removes files
$ git checkout feature-branch
# Switched to branch 'feature-branch'
2. Applying Stashed Changes
The stashed changes were later applied to the new branch using git stash pop, which resulted in a merge conflict that needed resolution.

Bash

$ git stash pop
# Auto-merging README.md
# CONFLICT (content): Merge conflict in README.md
# Unmerged paths:
# both modified: README.md

**Task 5: Checkout a Specific Commit (git log and git checkout)**
This task showed how to use git log to find a commit hash and then check out that specific point in history, resulting in a detached HEAD state.

1. Viewing History and Checking Out
The commit hash was identified using git log --oneline, and then used to check out that specific point in history.

Bash

$ git log --oneline
# 7628f1a (HEAD -> feature-branch) Changes The README.md file
# f3a5f6c (origin/main, origin/HEAD, main) removes files
# ... (list of commits)

$ git checkout 4c8c07c
# Note: switching to 4c8c07c.
# You are in 'detached HEAD' state.
The state was reverted by checking out the main branch.

Bash

$ git checkout main
# Switched to branch 'main'

**Task 6: Resetting Commits (Soft vs Hard Reset)**
This task compared git reset --soft (preserving changes) and git reset --hard (discarding changes).

1. The git reset --soft HEAD~1
A soft reset moved the HEAD pointer back by one commit (HEAD~1) but kept the changes from the reverted commit in the staging area (to be committed).

Bash

$ git commit -m "Added test line"
# [main 4639c5a] Added test line
$ git reset --soft HEAD~1
# ... HEAD is now at 4639c5a Added test line (new HEAD pointer)
# git status showed changes to be committed (staging area)
2. The git reset --hard HEAD~1
A hard reset moved the HEAD pointer back by one commit and discarded all changes associated with the reverted commit from the working directory and staging area.

Bash

$ git commit -m "Second Test commit"
# [main 6688456] Second Test commit
$ git reset --hard HEAD~1
# HEAD is now at 4639c5a Added test line

**Task 7: Amending the Last Commit (git revert)**
This task demonstrated how to safely undo a commit by using git revert, which creates a new commit that undoes the changes of a specified commit.

1. Commit and Revert
The commit that created temp.txt (4c6698e) was undone using git revert.

Bash

$ echo "temporary text" >> temp.txt
$ git commit -m "Added temp text file"
# [main 4c6698e] Added temp text file

$ git revert 4c6698e
# [main 5bb4583] Revert "Added temp text file"
# 1 file changed, 1 deletion(-)
# delete mode 100644 temp.txt

**Task 8: Force Push (With Caution - git push --force)**
This task demonstrated how to use git push --force to overwrite a remote branch after rewriting history locally.

1. Rewriting History Locally
A new branch test-force was created, pushed, and then the last commit was removed using a hard reset (rewriting local history).

Bash

$ git checkout -b test-force
# Switched to a new branch 'test-force'
$ git push origin test-force

$ git reset --hard HEAD~1
# HEAD is now at 4c6698e Added temp text file
2. Force Pushing to Overwrite Remote
A normal push was rejected because the local history was behind the remote. The issue was resolved by using git push --force, which overwrites the remote branch.

Bash

$ git push origin test-force
# error: failed to push some refs... tip of your current branch is behind

$ git push origin test-force --force
# 5bb4583...4c6698e test-force -> test-force (Forced update)

**Task 10: Running Gitea in GitHub Codespaces via Docker Compose**
This task involved deploying a self-hosted Git service (Gitea) using Docker Compose within GitHub Codespaces.

1. Deployment and Access
The Gitea service was started using Docker Compose, creating the necessary containers.

Bash

$ docker compose up -d
# ... Container gitea_db Started
# ... Container gitea Started
A new repository named maira_gitea was created within the Gitea instance for demonstration.

**Task 11: Creating a GitHub Pages Portfolio Site**
This task involved setting up a basic portfolio site using GitHub Pages.

1. Repository Creation and Configuration
A new repository named mairamalik.github.io was created and populated with portfolio files, including images.png, index.html, and style.css. The repository was configured to build the site from the main branch.

Outcome: A professional profile page was successfully rendered using the GitHub Pages service.
