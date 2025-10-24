# Cloud Computing Lab Report: Installation and System Management

---

**Student:** Maira Malik  
**Registration No.:** 2023-BSE-040  
**Subject:** Cloud Computing  
**Lab #:** 5  

---

## Task 1: Installing and Removing Default Java Runtime Environment (JRE)

The task involved attempting to run `java`, installing the **default JRE** (which installed **OpenJDK 21.0.8**), and then removing it.

### Initial State
Running the `java` command initially showed it was not found, but provided several installation options.

```bash
maira840@ubuntu64:~$ java
Installation
The default-jre package was installed using the apt command.

bash
Copy code
sudo apt install default-jre
Installation confirmed a set of packages would be installed, including openjdk-21-jre.

Verification
The installed Java version was verified:

bash
Copy code
java -version
Output:

java
Copy code
openjdk 21.0.8 2025-07-15
OpenJDK Runtime Environment (build 21.0.8+9-Ubuntu-0ubuntu124.04.1)
OpenJDK 64-Bit Server VM (build 21.0.8+9-Ubuntu-0ubuntu124.04.1, mixed mode, sharing)
Removal
The default JRE package was removed.

bash
Copy code
sudo apt remove default-jre
sudo apt autoremove
Task 2: Installing and Removing Default JRE using apt-get
This task repeated the installation process using the apt-get command with a package list update.

Package List Update
bash
Copy code
sudo apt-get update
Installation
bash
Copy code
sudo apt-get install default-jre -y
Verification
bash
Copy code
java -version
Output:

java
Copy code
openjdk 21.0.8 2025-07-15
OpenJDK Runtime Environment (build 21.0.8+9-Ubuntu-0ubuntu124.04.1)
OpenJDK 64-Bit Server VM (build 21.0.8+9-Ubuntu-0ubuntu124.04.1, mixed mode, sharing)
Removal
bash
Copy code
sudo apt-get remove default-jre
Task 3: Package Management — apt update vs apt upgrade
Commands Executed
bash
Copy code
sudo apt update
sudo apt upgrade
Conceptual Difference
apt update: Refreshes the system’s package list from repositories, informing the system of the latest available versions.

apt upgrade: Installs newer versions of packages that are already installed on the system.

Task 4: Installing and Verifying Visual Studio Code (VS Code)
Visual Studio Code was installed using the snap package manager with the --classic flag.

Installation
bash
Copy code
sudo snap install --classic code
Verification (snap list)
bash
Copy code
snap list code
Output:

pgsql
Copy code
Name    Version      Rev      Tracking       Publisher   Notes
code    7d842fb8     latest/stable vscode     classic
Version Check
bash
Copy code
code --version
Output:

Copy code
1.105.1
7d842fb85a0275a4a8e4d7e040d2625abbf7f084
x64
Task 5: Remote Desktop (xrdp) Setup
The task involved setting up the xrdp service for graphical remote access, starting with an SSH connection.

Initial Connection (SSH)
bash
Copy code
ssh maira040@192.168.238.129
System Info:

nginx
Copy code
Ubuntu 24.04.3 LTS
IPv4: 192.168.238.129
xrdp Installation and Configuration
bash
Copy code
sudo apt install xrdp pipewire-module-xrdp -y
sudo systemctl enable --now xrdp
sudo systemctl status xrdp
Service confirmed as active and listening on port 3389.

Set the default desktop environment to xfce4:

bash
Copy code
echo xfce4-session > ~/.xsession
Task 6: LightDM Configuration
Installed LightDM display manager and configured the XFCE session.

Installation
bash
Copy code
sudo apt install lightdm lightdm-gtk-greeter -y
Configuration
bash
Copy code
sudo mkdir -p /etc/lightdm/lightdm.conf.d
echo -e "[Seat:*]\ngreeter-session=lightdm-gtk-greeter\nuser-session=xfce\nautologin-user-timeout=0" | sudo tee /etc/lightdm/lightdm.conf.d/99-xfce.conf
Resulting Configuration:

ini
Copy code
[Seat:*]
greeter-session=lightdm-gtk-greeter
user-session=xfce
autologin-user-timeout=0
Task 7: Installing and Removing Google Chrome Web Browser
Adding the Google Signing Key
bash
Copy code
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg
Adding Repository
bash
Copy code
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
Installation
bash
Copy code
sudo apt update
sudo apt install google-chrome-stable
Verification
bash
Copy code
google-chrome --version
Output:

nginx
Copy code
Google Chrome 129.0.6647.165
Removal
bash
Copy code
sudo apt remove google-chrome-stable
sudo rm /etc/apt/keyrings/google-chrome.gpg
sudo rm /etc/apt/sources.list.d/google-chrome.list
Task 8: Installing and Removing Apache Web Server
Installation
bash
Copy code
sudo apt install apache2
Verification
bash
Copy code
sudo systemctl status apache2
sudo ufw status
sudo netstat -tuln | grep 80
Apache confirmed active and listening on port 80.

Removal
bash
Copy code
sudo apt remove apache2
Task 9: Finding Files (find Command)
Find all .conf files in /etc
bash
Copy code
sudo find /etc -name "*.conf"
Find the motd file
bash
Copy code
sudo find / -name "motd"
Output:

bash
Copy code
/etc/motd
Find files larger than 20MB in /usr/share/doc
bash
Copy code
sudo find /usr/share/doc -size +20M
(No results found.)

Task 10: Filtering Content (grep Command)
Find "root" in /etc/passwd with line numbers
bash
Copy code
grep -n "root" /etc/passwd
Output:

ruby
Copy code
1:root:x:0:0:root:/root:/bin/bash
Find "lightdm" in config file
bash
Copy code
grep "lightdm" /etc/lightdm/lightdm.conf.d/99-xfce.conf
Output:

ini
Copy code
greeter-session=lightdm-gtk-greeter
Show lines in /var/log/syslog without "error"
bash
Copy code
grep -v "error" /var/log/syslog
(Multiple non-error lines displayed.)

Task 11: Displaying File Content (cat, less, head, tail)
View file with cat
bash
Copy code
cat /etc/lightdm/lightdm.conf.d/99-xfce.conf
View with less
bash
Copy code
less /etc/passwd
Show first 5 lines
bash
Copy code
head -n 5 /etc/lightdm/lightdm.conf.d/99-xfce.conf
Show last 5 lines
bash
Copy code
tail -n 5 /etc/passwd
Task 12: Directory and File Management
List all files
bash
Copy code
ls -l
Create a file
bash
Copy code
touch demo.txt
Create a directory
bash
Copy code
mkdir test_dir
Remove the file and directory
bash
Copy code
rm demo.txt
rmdir test_dir
✅ Lab Summary:
In this lab, we practiced system management in Ubuntu, including installing and removing software packages, configuring remote desktop and display managers, managing repositories, using core Linux commands (find, grep, cat, ls, etc.), and understanding package management tools (apt and snap).

