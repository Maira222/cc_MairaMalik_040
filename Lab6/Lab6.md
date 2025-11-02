
# Cloud Computing - Lab #06: Linux User and File Management

---

## Metadata
- **Name:** Maira Malik  
- **Registration No.:** 2023-BSE-040  
- **Subject:** Cloud Computing  
- **Lab #:** 06  

---

## Lab Tasks and Execution Details

### Task 1: Switch to Root with `su -` and Back to Normal User

1. Set a password for the root user:
   ```bash
   maira040@ubuntu64:$ sudo passwd root
   [sudo] password for maira040: 
   New password: 
   Retype new password: 
   passwd: password updated successfully
````

2. Switch to the root user and verify identity:

   ```bash
   maira040@ubuntu64:$ su
   Password: 
   root@ubuntu64:# whoami
   root
   root@ubuntu64:# id
   uid=0(root) gid=0(root) groups=0(root)
   ```

3. Exit the root session:

   ```bash
   root@ubuntu64:# exit
   logout
   maira040@ubuntu64:$ whoami
   maira040
   ```

---

### Task 2: Create User `tom` and Verify in `passwd` / `group` / `shadow`

1. Create the user:

   ```bash
   maira040@ubuntu64:$ sudo adduser tom
   Info: adding user tom...
   Info: Adding new group tom (1001)...
   Info: Adding new user tom (1001) with group tom (1001)...
   Info: Creating home directory /home/tom
   Info: Copying files from /etc/skel...
   New password: 
   Retype new password: 
   passwd: password updated successfully
   ```

2. Verify entries:

   ```text
   /etc/passwd:
   tom:x:1001:1001:tom:/home/tom:/bin/bash

   /etc/shadow:
   tom:$y$j9T$y.WKG7IsHCNCjsWD1hpt21$ocV9groJY3dUu3t3AsiECNR6w14WNbQ4vewU1RMGck4:20394:0:99999:7:::

   /etc/group:
   tom:x:1001:
   ```

---

### Task 3: Create Groups and Modify User `tom`

1. Create groups:

   ```bash
   sudo addgroup developer
   sudo addgroup devops
   sudo addgroup designer
   ```

2. Change `tom`’s primary group:

   ```bash
   sudo usermod -g designer tom
   id tom
   uid=1001(tom) gid=1004(designer) groups=1004(designer),100(users)
   ```

3. Add secondary groups:

   ```bash
   sudo usermod -aG developer,devops tom
   id tom
   uid=1001(tom) gid=1004(designer) groups=1004(designer),100(users),1002(developer),1003(devops)
   groups tom
   tom designer users developer devops
   ```

---

### Task 4: Create/Delete Users and Groups

1. Create user `Jerry`:

   ```bash
   sudo adduser Jerry
   ```

2. Create user `Scooby`:

   ```bash
   sudo useradd Scooby
   ```

3. Set password for `Scooby`:

   ```bash
   sudo passwd Scooby
   New password:
   Retype new password:
   passwd: password updated successfully
   ```

4. Create and assign home directory:

   ```bash
   sudo mkdir -p /home/Scooby
   sudo chown Scooby:Scooby /home/Scooby
   sudo chmod 750 /home/Scooby
   ls -ld /home/Scooby
   drwxr-x--- 2 Scooby Scooby 4096 Nov 2 06:59 /home/Scooby
   ```

5. Change default shell:

   ```bash
   sudo usermod -s /bin/bash Scooby
   su Scooby
   Scooby@ubuntu64:~$
   ```

6. Create groups `jolly` and `anime`:

   ```bash
   sudo addgroup jolly
   sudo groupadd anime
   ```

---

### Task 5: Create User `student`, Files, and Identify File Types

1. Create user and files:

   ```bash
   sudo adduser student
   su student
   student@ubuntu64:$ touch file1
   student@ubuntu64:$ mkdir -p dir1
   student@ubuntu64:$ touch dir1/file1
   ```

2. Attempt to change owner/group (fails due to permissions):

   ```bash
   sudo chown tom file1
   sudo chgrp devops file1
   student is not in the sudoers file.
   ```

3. Identify file types:

   ```bash
   file file1 dir1 /dev/null
   file1: empty
   dir1: directory
   /dev/null: character special (1/3)
   ```

---

### Task 6: Change Permissions (Symbolic Mode)

| Command               | Before       | After        |
| :-------------------- | :----------- | :----------- |
| `chmod -rwx file1`    | `-rw-rw-r--` | `----------` |
| `chmod +r file1`      | `----------` | `-r--r--r--` |
| `chmod u+x file1`     | `-r--r--r--` | `-r-xr--r--` |
| `chmod ug+w file1`    | `-r-xr--r--` | `-rwxrw-r--` |
| `chmod ugo-rwx file1` | `-rwxrw-r--` | `----------` |

---

### Task 7: Change Permissions (Set Symbolic Form)

| Command                         | Before       | After        |
| :------------------------------ | :----------- | :----------- |
| `chmod u=rwx,g=rwx,o=rwx file1` | `----------` | `-rwxrwxrwx` |
| `chmod g=rw,o=rw file1`         | `-rwxrwxrwx` | `-rwxrw-rw-` |
| `chmod u,g=,o= file1`           | `-rwxrw-rw-` | `----------` |

---

### Task 8: Change Permissions (Numeric Mode)

| Command           | Numeric | Result       |
| :---------------- | :------ | :----------- |
| `chmod 777 file1` | 777     | `-rwxrwxrwx` |
| `chmod 700 file1` | 700     | `-rwx------` |
| `chmod 744 file1` | 744     | `-rwxr--r--` |
| `chmod 640 file1` | 640     | `-rw-r-----` |
| `chmod 664 file1` | 664     | `-rw-rw-r--` |
| `chmod 775 file1` | 775     | `-rwxrwxr-x` |
| `chmod 750 file1` | 750     | `-rwxr-x---` |

---

### Task 9: Pipes, Pagers, Grep, and Redirects with `/var/log/syslog`

1. Filter and show first 10 lines:

   ```bash
   sudo grep -E 'fail|error' /var/log/syslog | head
   ```

2. Redirect output to file:

   ```bash
   sudo grep -i systemd /var/log/syslog > syslog_systemd.txt
   ```

---

### Task 10 & 11: Shell Script (`setup.sh`)

```bash
#!/bin/bash

# --- Task 10: Variables, Command Substitution, File/Dir Checks, Permissions ---

var1="Hello from Lab 6"
echo "var1: $var1"

allFiles="ls -l"
echo "allFiles (ls -l):"
echo "$allFiles"

if [ -d "dir1" ]; then
    echo "Directory dir1 exists."
else
    echo "Directory dir1 does not exist. Creating..."
    mkdir -p "dir1"
    echo "Directory dir1 created."
fi

if [ -f "dir1/file2" ]; then
    echo "file2 already exists."
else
    echo "file2 does not exist. Creating..."
    touch "dir1/file2"
    chmod a-rwx "dir1/file2"
    echo "file2 created."
fi

echo "Setting permission (750) for dir1/file2..."
chmod 750 "dir1/file2"
ls -l "dir1/file2"

# --- Task 11: Argument Comparisons ---

num=$1
str=$2

if [ "$num" -eq 10 ]; then
    echo "$num is equal to 10 (-eq)."
else
    echo "$num is Not equal to 10 (-eq)."
fi

if [ "$num" -ne 10 ]; then
    echo "$num is not equal to 10 (-ne)."
else
    echo "$num is equal to 10 (-ne false)."
fi

if [ "$num" -gt 10 ]; then
    echo "$num is greater than 10 (-gt)."
else
    echo "$num is not greater than 10 (-gt)."
fi

if [ "$num" -lt 10 ]; then
    echo "$num is less than 10 (-lt)."
else
    echo "$num is NOT less than 10 (-lt)."
fi
```

---

### Example Script Outputs

| Command                 | Output Summary                                                                                                                   |
| :---------------------- | :------------------------------------------------------------------------------------------------------------------------------- |
| `./setup.sh 10 student` | `10 is equal to 10 (-eq)` → `10 is equal to 10 (-ne false)` → `10 is not greater than 10 (-gt)` → `10 is NOT less than 10 (-lt)` |
| `./setup.sh 7 student`  | `7 is Not equal to 10 (-eq)` → `7 is not equal to 10 (-ne)` → `7 is not greater than 10 (-gt)` → `7 is less than 10 (-lt)`       |
| `./setup.sh 12 student` | `12 is Not equal to 10 (-eq)` → `12 is not equal to 10 (-ne)` → `12 is greater than 10 (-gt)` → `12 is NOT less than 10 (-lt)`   |
| `./setup.sh 5 student`  | `5 is Not equal to 10 (-eq)` → `5 is not equal to 10 (-ne)` → `5 is not greater than 10 (-gt)` → `5 is less than 10 (-lt)`       |

---

## Summary

This lab demonstrated:

* Managing users, groups, and permissions in Linux.
* Understanding symbolic and numeric permission modes.
* Using text filters (`grep`, `head`) and redirection.
* Creating and running basic shell scripts for automation.

---
Cloud Computing report.
```
