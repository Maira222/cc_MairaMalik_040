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
Switch to the root user and verify identity:

bash
Copy code
maira040@ubuntu64:$ su
Password: 
root@ubuntu64:# whoami
root
root@ubuntu64:# id
uid=0(root) gid=0(root) groups=0(root)
Exit the root session:

bash
Copy code
root@ubuntu64:# exit
logout
maira040@ubuntu64:$ whoami
maira040
Task 2: Create User tom and Verify in passwd / group / shadow
Create the user:

bash
Copy code
maira040@ubuntu64:$ sudo adduser tom
Info: adding user tom...
Info: Adding new group tom (1001)...
Info: Adding new user tom (1001) with group tom (1001)...
Info: Creating home directory /home/tom
Info: Copying files from /etc/skel...
New password: 
Retype new password: 
passwd: password updated successfully
Verify entries:

text
Copy code
/etc/passwd:
tom:x:1001:1001:tom:/home/tom:/bin/bash

/etc/shadow:
tom:$y$j9T$y.WKG7IsHCNCjsWD1hpt21$ocV9groJY3dUu3t3AsiECNR6w14WNbQ4vewU1RMGck4:20394:0:99999:7:::

/etc/group:
tom:x:1001:
Task 3: Create Groups and Modify User tom
Create groups:

bash
Copy code
sudo addgroup developer
sudo addgroup devops
sudo addgroup designer
Change tom’s primary group:

bash
Copy code
sudo usermod -g designer tom
id tom
uid=1001(tom) gid=1004(designer) groups=1004(designer),100(users)
Add secondary groups:

bash
Copy code
sudo usermod -aG developer,devops tom
id tom
uid=1001(tom) gid=1004(designer) groups=1004(designer),100(users),1002(developer),1003(devops)
groups tom
tom designer users developer devops
Task 4: Create/Delete Users and Groups
Create user Jerry:

bash
Copy code
sudo adduser Jerry
Create user Scooby:

bash
Copy code
sudo useradd Scooby
Set password for Scooby:

bash
Copy code
sudo passwd Scooby
New password:
Retype new password:
passwd: password updated successfully
Create and assign home directory:

bash
Copy code
sudo mkdir -p /home/Scooby
sudo chown Scooby:Scooby /home/Scooby
sudo chmod 750 /home/Scooby
ls -ld /home/Scooby
drwxr-x--- 2 Scooby Scooby 4096 Nov 2 06:59 /home/Scooby
Change default shell:

bash
Copy code
sudo usermod -s /bin/bash Scooby
su Scooby
Scooby@ubuntu64:~$
Create groups jolly and anime:

bash
Copy code
sudo addgroup jolly
sudo groupadd anime
Task 5: Create User student, Files, and Identify File Types
Create user and files:

bash
Copy code
sudo adduser student
su student
student@ubuntu64:$ touch file1
student@ubuntu64:$ mkdir -p dir1
student@ubuntu64:$ touch dir1/file1
Attempt to change owner/group (fails due to permissions):

bash
Copy code
sudo chown tom file1
sudo chgrp devops file1
student is not in the sudoers file.
Identify file types:

bash
Copy code
file file1 dir1 /dev/null
file1: empty
dir1: directory
/dev/null: character special (1/3)
Task 6: Change Permissions (Symbolic Mode)
Command	Before	After
chmod -rwx file1	-rw-rw-r--	----------
chmod +r file1	----------	-r--r--r--
chmod u+x file1	-r--r--r--	-r-xr--r--
chmod ug+w file1	-r-xr--r--	-rwxrw-r--
chmod ugo-rwx file1	-rwxrw-r--	----------

Task 7: Change Permissions (Set Symbolic Form)
Command	Before	After
chmod u=rwx,g=rwx,o=rwx file1	----------	-rwxrwxrwx
chmod g=rw,o=rw file1	-rwxrwxrwx	-rwxrw-rw-
chmod u,g=,o= file1	-rwxrw-rw-	----------

Task 8: Change Permissions (Numeric Mode)
Command	Numeric	Result
chmod 777 file1	777	-rwxrwxrwx
chmod 700 file1	700	-rwx------
chmod 744 file1	744	-rwxr--r--
chmod 640 file1	640	-rw-r-----
chmod 664 file1	664	-rw-rw-r--
chmod 775 file1	775	-rwxrwxr-x
chmod 750 file1	750	-rwxr-x---

Task 9: Pipes, Pagers, Grep, and Redirects with /var/log/syslog
Filter and show first 10 lines:

bash
Copy code
sudo grep -E 'fail|error' /var/log/syslog | head
Redirect output to file:

bash
Copy code
sudo grep -i systemd /var/log/syslog > syslog_systemd.txt
Task 10 & 11: Shell Script (setup.sh)
bash
Copy code
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
Example Script Outputs
Command	Output Summary
./setup.sh 10 student	10 is equal to 10 (-eq) → 10 is equal to 10 (-ne false) → 10 is not greater than 10 (-gt) → 10 is NOT less than 10 (-lt)
./setup.sh 7 student	7 is Not equal to 10 (-eq) → 7 is not equal to 10 (-ne) → 7 is not greater than 10 (-gt) → 7 is less than 10 (-lt)
./setup.sh 12 student	12 is Not equal to 10 (-eq) → 12 is not equal to 10 (-ne) → 12 is greater than 10 (-gt) → 12 is NOT less than 10 (-lt)
./setup.sh 5 student	5 is Not equal to 10 (-eq) → 5 is not equal to 10 (-ne) → 5 is not greater than 10 (-gt) → 5 is less than 10 (-lt)

Summary
This lab demonstrated:

Managing users, groups, and permissions in Linux.

Understanding symbolic and numeric permission modes.

Using text filters (grep, head) and redirection.

Creating and running basic shell scripts for automation.

