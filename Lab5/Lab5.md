Markdown# Cloud Computing Lab Report: Installation and System Management

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
maira840@ubuntu64: java
InstallationThe default-jre package was installed using the apt command.Bashsudo apt install default-jre
Installation confirmed a set of packages would be installed, including openjdk-21-jre.VerificationThe installed Java version was verified using java -version.Bashmaira040@ubuntu64:~$ java -version
openjdk 21.0.8 2025-07-15
OpenJDK Runtime Environment (build 21.0.8+9-Ubuntu-0ubuntu124.04.1)
OpenJDK 64-Bit Server VM (build 21.0.8+9-Ubuntu-0ubuntu124.04.1, mixed mode, sharing)
RemovalThe default JRE package was removed.Bashsudo apt remove default-jre
This also left behind automatically installed packages, which could be removed with sudo apt autoremove.Task 2: Installing and Removing Default JRE using apt-getThis task repeated the installation process using the apt-get command with package list update.Package List UpdateThe package list was updated successfully.Bashmaira040@ubuntu64:~$ sudo apt-get update
InstallationThe default-jre package was installed with the -y flag for automatic confirmation.Bashmaira040@ubuntu64:~$ sudo apt-get install default-jre -y
VerificationThe installed Java version remained OpenJDK 21.0.8.Bashmaira040@ubuntu64: Java-version
openjdk 21.0.8 2025-07-15
OpenJDK Runtime Environment (build 21.6.8+9-Ubuntu-0ubuntu124.04.1)
OpenJDK 64-Bit Server VM (build 21.0.8+9-Ubuntu-eubuntu124.04.1, mixed mode, sharing)
RemovalThe default JRE package was removed again.Bashmaira040@ubuntu64 sudo apt-get remove default-jre
Task 3: Package Management: apt update vs apt upgradeThis task focused on the difference between the apt update and apt upgrade commands.Commands ExecutedUpdate package lists.Bashsudo apt update
Upgrade installed packages.Bashsudo apt upgrade
Conceptual Differenceapt update: Refreshes the system's package list from the repositories, informing the computer about the latest available software versions.apt upgrade: Installs the newer versions for packages that are already installed on the system.Task 4: Installing and Verifying Visual Studio Code (VS Code)Visual Studio Code was installed using the snap package manager with the --classic flag.InstallationBashmaira040@ubuntu64:"$ sudo snap install --classic code
Verification (snap list)The installation status was confirmed using snap list code.NameVersionRevTrackingPublisherNotescode7d842fb8211latest/stablevscodeclassicVersion CheckThe installed VS Code version was verified.Bashmaira040@ubuntu64:~$ code --version
1.105.1
7d842fb85a0275a4a8e4d7e040d2625abbf7f084
x64
Task 5: Remote Desktop (xrdp) SetupThe task involved setting up the Remote Desktop Protocol (xrdp) service for graphical remote access, starting with an SSH connection.Initial Connection (SSH)An SSH connection was established to the remote host.BashUsers\BOSS>ssh maira040@192.168.238.129
The system was running Ubuntu 24.84.3 LTS with IPv4 address 192.168.238.129.xrdp and ConfigurationThe xrdp service and related packages (including pipewire-module-xrdp) were installed.Enable and start the xrdp service:Bashsudo systemctl enable --now xrdp
Check the service status:Bashsudo systemctl status xrdp
Status confirmed as active (running).The daemon was listening on port 3389.Configure the user's session for Remote Desktop (setting the default desktop environment to xfce4-session):Bashecho xfce4-session > ~/.xsession
Task 6: LightDM ConfigurationThe Light Display Manager (lightdm) and its GTK greeter were installed, and a configuration file was created for the xfce session.InstallationBashsudo apt install lightdm lightdm-gtk-greeter -y
ConfigurationA directory and configuration file (99-xfce.conf) were created to set the display manager and the default user session.Bashsudo mkdir -p /etc/lightdm/lightdm.conf.d
echo -e "[Seat:*]\ngreeter-session=lightdm-gtk-greeter\nuser-session=xfce\nautologin-user-timeout=0" | sudo tee /etc/lightdm/lightdm.conf.d/99-xfce.conf
Resulting configuration in /etc/lightdm/lightdm.conf.d/99-xfce.conf:Ini, TOML[Seat:*]
greeter-session=lightdm-gtk-greeter
user-session=xfce
autologin-user-timeout=0
Task 7: Installing and Removing the Google Chrome Web BrowserThe task involved adding the Google Chrome repository and key, installing the browser, verifying the version, and then removing it.Adding the Google Signing Key (wget)Bashmaira040@ubuntu64:~$ wget -q -O - [https://dl.google.com/linux/linux_signing_key.pub](https://dl.google.com/linux/linux_signing_key.pub) | sudo gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg
Adding the Google Chrome RepositoryBashecho "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] [http://dl.google.com/linux/chrome/deb/](http://dl.google.com/linux/chrome/deb/) stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
Updating package lists and Installing Google ChromeBashsudo apt update
sudo apt install google-chrome-stable
VerificationBashmaira040@ubuntu64:~$ google-chrome --version
Google Chrome 129.0.6647.165
RemovalBashsudo apt remove google-chrome-stable
Removing Repository Key and ListBashsudo rm /etc/apt/keyrings/google-chrome.gpg
sudo rm /etc/apt/sources.list.d/google-chrome.list
Task 8: Installing and Removing Apache Web ServerThe task involved installing the Apache web server, verifying its status, and then removing it.InstallationBashsudo apt install apache2
Verification (Status Check)Bashsudo systemctl status apache2
Status was confirmed as active (running).Verification (Firewall Check)Bashsudo ufw status
Output showed firewall status is inactive.Verification (Check listening ports - netstat)Bashsudo netstat -tuln | grep 80
Output showed Apache is listening on 0.0.0.0:80 and [::]:80.RemovalBashsudo apt remove apache2
Task 9: Finding Files (find Command)The task involved using the find command to locate files based on different criteria.Find all files in /etc directory with .conf extension.Bashsudo find /etc -name "*.conf"
(Output lists many .conf files.)Find the file named motd anywhere in the file system.Bashsudo find / -name "motd"
Output: /etc/motd.Find files in /usr/share/doc directory with size greater than 20MB.Bashsudo find /usr/share/doc -size +20M
(Output implies no such files were found in the current environment.)Task 10: Filtering Content (grep Command Practice)The task involved using the grep command to filter and search for text within files.Find all occurrences of "root" in the /etc/passwd file and show line numbers.Bashgrep -n "root" /etc/passwd
Output: 1:root:x:0:0:root:/root:/bin/bash.Find the word "lightdm" in /etc/lightdm/lightdm.conf.d/99-xfce.conf.Bashgrep "lightdm" /etc/lightdm/lightdm.conf.d/99-xfce.conf
Output: greeter-session=lightdm-gtk-greeter.Find all lines in /var/log/syslog that do not contain the word "error".Bashgrep -v "error" /var/log/syslog
(Output shows multiple lines from the syslog without the word "error".)Task 11: Displaying File Content (cat, less, head, tail)The task involved using different commands to view parts of or entire files.Display the entire content of /etc/lightdm/lightdm.conf.d/99-xfce.conf using cat.Bashcat /etc/lightdm/lightdm.conf.d/99-xfce.conf
Output:[Seat:*]
greeter-session=lightdm-gtk-greeter
user-session=xfce
autologin-user-timeout=0
View the content of /etc/passwd using less.Bashless /etc/passwd
(Output is the start of the /etc/passwd file.)Display the first 5 lines of /etc/lightdm/lightdm.conf.d/99-xfce.conf using head.Bashhead -n 5 /etc/lightdm/lightdm.conf.d/99-xfce.conf
(Output shows the full content of the file, as it is less than 5 lines.)Display the last 5 lines of /etc/passwd using tail.Bashtail -n 5 /etc/passwd
(Output shows the last 5 user/system entries from /etc/passwd.)Task 12: Directory and File Management (ls, touch, mkdir, rm, rmdir)The task involved basic file and directory creation and deletion in the home directory.List all files in the current directory (ls -l).Bashls -l
(Output is a long list of files/directories with permissions/details.)Create a file named demo.txt in the home directory.Bashtouch demo.txt
Create a directory named test_dir in the home directory.Bashmkdir test_dir
Remove the file demo.txt.Bashrm demo.txt
Remove the directory test_dir.Bashrmdir test_dir
