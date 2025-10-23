# Cloud Computing - Lab #04

**Student:** Maira Malik
**Registration No.:** 2023-BSE-040

---

## Virtual Machine Settings

The following hardware configurations were used for the Virtual Machine (VM):

| Device | Summary | Primary Configuration |
| :--- | :--- | :--- |
| **Memory** | 4 GB | 4096 MB |
| **Processors** | 2 | - |
| **Hard Disk (SCSI)** | 20 GB | - |
| **CD/DVD (SATA)** | Using file D: Google download | - |
| **Network Adapter** | NAT | - |
| **USB Controller** | Present | - |
| **Sound Card** | Auto detect | - |
| **Display** | Auto detect | - |
| **Notes** | - | [cite_start]Maximum recommended memory: 16 GB [cite: 703] |

---

## Lab Tasks and Command Line Outputs

### Task 1: Verify VM resources in VMware
* [cite_start]Verification performed. [cite: 704, 705]

### Task 2: Start VM and log in

#### 1. Initial VM Terminal Login
The user logged in to the Ubuntu VM directly.

```bash
Ubuntu 24.04.3 LTS ubuntu64 tty1
ubuntu64 login: maira840
Password:
Welcome to Ubuntu 24.04.3 LTS (GNU/Linux 6.8.0-71-generic x86_64)
Documentation: [https://help.ubuntu.com](https://help.ubuntu.com)
Management: [https://landscape.canonical.com](https://landscape.canonical.com)
Support: [https://ubuntu.com/pro](https://ubuntu.com/pro)
System Information as of Thu Oct 23 01:04:11 PM UTC 2025
System load: 0.08
Processes: 245
Usage of /: 45.3% of 9.75GB
Users logged in: 1
Memory usage: 7%
IPv4 address for ens33: 192.168.238.129
...
To check for new updates run: sudo apt update
maira040@ubuntu64:
[cite_start]``` [cite: 708, 711, 717-724, 726, 730, 731]

#### 2. SSH Login from Host Terminal
The user logged in via SSH from a Windows host machine.

```bash
C:\Users\BOSS>ssh maira040@192.168.238.129
maira040@192.168.238.129's password:
Welcome to ubuntu 24.64.3 LTS (GNU/Linux 6.8.0-71-generic x86-64)
System information as of Thu Oct 23 01:08:32 PM UTC 2025
System load: 0.0
Usage of /: 45.4% of 9.75GB
Processes: 214
IPV4 address for ens33: 192.168.238.129
...
Last login: Fri Sep 20 16:43:32 2025 from 192.168.238.1

maira040@ubuntu64:~$ whoami
maira040

maira040@ubuntu64:~$ pwd
/home/maira040
maira040@ubuntu64:~$
[cite_start]``` [cite: 734-736, 742-744, 747, 748, 750, 757, 758, 760-762]

### Task 3: Filesystem exploration root tree and dotfiles

| Command | Output Summary |
| :--- | :--- |
| `ls -la /bin` | [cite_start]Symbolic link: `lrwxrwxrwx 1 root root 7 Apr 22 2024 /bin ->` [cite: 768, 769] |
| `ls -la /sbin` | [cite_start]Symbolic link: `lrwxrwxrwx 1 root root 8 Apr 22 2024 /sbin -> sbin` [cite: 770, 771] |
| `ls -la /usr` | [cite_start]Shows system directories like `bin`, `lib`, `share`, etc. [cite: 774-777, 779-781] |
| `ls -la /opt` | [cite_start]Shows empty directory structure: `total 8` [cite: 809, 810] |
| `ls -la /var` | [cite_start]Shows variable data directories like `log`, `mail`, `tmp`, etc. [cite: 816-818, 820-825, 827-831, 834] |
| `ls -ls /tmp` | [cite_start]Shows temporary file system: `total 52` [cite: 836-849] |
| `ls -la` (Home) | [cite_start]Shows user home files and directories, including dotfiles: [cite: 852, 854-861] |
| `cat answers.md` | [cite_start]Content: "In linux, **/bin** holds essential system commands, **/usr/bin** contains most user-installed programs, and **/usr/local/bin** stores manually installed software. This separation keeps system tools, package-managed apps, and user-added programs organized and safe from overwriting." [cite: 862-864] |

### Task 4: Essential CLI tasks navigation and file operations

| Step | Command Executed | Output / Description |
| :--- | :--- | :--- |
| 1 | `mkdir -p lab4/workspace/python_project` | [cite_start]Created nested directories. [cite: 867] |
| 2 | `cd ~/lab4/workspace/python_project` | [cite_start]Changed directory. [cite: 869] |
| 3-5 | `pwd`, `nano README.md`, `nano main.py`, `nano .env` | Verified current path: `/home/maira040/lab4/workspace/python_project`. [cite_start]Created `README.md` (`Lab 4 README`), `main.py` (`print ("hello Lab4")`), and `.env` (`ENV lab4_`). [cite: 873, 875, 877, 882] |
| 6 | `ls -la` | [cite_start]Verified file creation: `README.md`, `main.py`, `.env` exist. [cite: 883-896] |
| 8 | `cp README.md README.copy.md` | [cite_start]Copied `README.md` to `README.copy.md`. [cite: 900] |
| 9 | `mv README.copy.md README.dev.md` | [cite_start]Renamed `README.copy.md` to `README.dev.md`. [cite: 902] |
| 10 | `rm README.dev.md` | [cite_start]Removed `README.dev.md`. [cite: 904] |
| 11 | `mkdir -p ~/lab4/workspace/java_app` | [cite_start]Created `java_app` directory. [cite: 906] |
| 12 | `cp -r /lab4/workspace/python_project /lab4/workspace/java_app_copy` | [cite_start]Copied the `python_project` directory recursively. [cite: 908] |
| 13 | `ls -la /lab4/workspace` | [cite_start]Verified new directories: `java_app` and `java_app_copy`. [cite: 910-913] |

### Task 5: System info, resources & processes

#### 1. Kernel Information
```bash
maira040@ubuntu64:/lab4/workspace/python_project$ uname -a
Linux ubuntu64 6.8.0-71-generic #71-Ubuntu SMP PREEMPT_DYNAMIC Tue Jul 22 16:52:38 UTC 2025 x86_64 x86_64 x86_64 GNU/Linux
[cite_start]``` [cite: 924]

#### 2. CPU Information (Partial)
* [cite_start]**Vendor ID**: GenuineIntel [cite: 953]
* [cite_start]**Model Name**: Intel(R) Core(TM) I5-835AU CPU 1.74GHZ [cite: 956]
* [cite_start]**CPU MHz**: 1056.001 [cite: 962]
* [cite_start]**Cache Size**: 6144 KB [cite: 964]

#### 3. Memory Usage
```bash
maira040@ubuntu64:$ free -h
              total        used        free      shared  buff/cache   available
Mem:          3.8Gi       501Mi       3.2Gi         1.5Mi       335Mi       3.3Gi
Swap:         1.9Gi          0B       1.9Gi
[cite_start]``` [cite: 674]

#### 4. Disk Free Space
```bash
maira040@ubuntu64:$ df -h
Filesystem                       Size  Used Avail Use% Mounted on
tmpfs                            387M  1.5M  386M   1% /run
/dev/mapper/ubuntu--vg-ubuntu    9.8G  4.5G  4.8G  49% /
tmpfs                            1.9G     0  1.9G   0% /dev/shm
/dev/sda2                        1.6G  100M  1.5G   7% /boot
[cite_start]``` [cite: 675]

#### 5. OS Release Information
```bash
maira040@ubuntu64:$ cat /etc/os-release
PRETTY_NAME="Ubuntu 24.04.3 LTS"
NAME="Ubuntu"
VERSION_ID="24.04"
VERSION="24.04.3 LTS (Noble Numbat)"
VERSION_CODENAME=noble
ID=ubuntu
ID_LIKE=debian
HOME_URL="[https://www.ubuntu.com/](https://www.ubuntu.com/)"
...
[cite_start]``` [cite: 676]

### Task 6: Users and account verification

#### 1. Creating a new user (`lab4user`)
```bash
maira040@ubuntu64:$ sudo adduser lab4user
# ... output showing creation of user, group (1001), home directory, and user information entered (Full Name: lab4user, Work Phone: 0300, etc.)
Info: Adding new user lab4user to supplemental / extra groups 'users'
Info: Adding user lab4user to group users
[cite_start]``` [cite: 679]

#### 2. Verifying user entry
```bash
maira040@ubuntu64:~$ getent passwd lab4user
lab4user:x:1001:1001:lab4user, 2,0300,0316,0400:/home/lab4user:/bin/bash
[cite_start]``` [cite: 680]

#### 4. Verifying sudo privileges
```bash
lab4user@ubuntu64:~$ sudo whoami
[sudo] password for lab4user:
lab4user is not in the sudoers file. This incident will be reported.
[cite_start]``` [cite: 680]

#### 6. Deleting the user
```bash
maira040@ubuntu64:~$ sudo deluser --remove-home lab4user
info: Removing user lab4user
[cite_start]``` [cite: 681]

### Task 7: Create a small demo script and run it

#### 1. Script Content (`~/lab4/workspace/run-demo.sh`)
```bash
# /bin/bash
"Lab 4 demo: current user is $(whoami)"
"Current time: $(date)"
uptime
free -h
[cite_start]``` [cite: 681]

#### 2. Change permissions and run
```bash
maira040@ubuntu64:~$ chmod +x ~/lab4/workspace/run-demo.sh
maira040@ubuntu64:~$ ~/lab4/workspace/run-demo.sh
Lab 4 demo: current user is maira040
Current time: Thu Oct 23 02:18:26 PM UTC 2025
14:18:26 up 1:16, 2 users, load average: 0.00, 0.00, 0.00
              total        used        free      shared  buff/cache   available
Mem:          3.8Gi       491Mi       3.2Gi         1.5Mi       335Mi       3.3Gi
Swap:         1.9Gi          0B       1.9Gi
maira040@ubuntu64:$
[cite_start]``` [cite: 681]
