#Maira Malik Cloud Computing Lab Report

**Name: Maira Malik** 
**Reg.no: 2023-BSE-040** 
**Subject: Cloud Computing** 



Task 1: Print & filter environment variables (LAB # 6)

Print all environment variables (printenv): The output shows many environment variables, including:


SHELL /bin/bash 


PWD=/home/maira040 


LOGNAME maina040 


HOME //maira040 home 


LANG=en US.UTF-8 


USER maira040 


PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/ 


MAIL /var/mall/maira040 


Filter environment variables using grep:

printenv | grep HOME

Output: grep USEHOME=/home/maira040 

Output (subsequent run): HOME=/home/maira040 

printenv | grep USER

Output: USER maira040 

Output (subsequent run): USER=maira040 

printenv | grep SHELL

Output: SHELL=/bin/bash 

Task 2: Export DB_* variables temporarily and observe scope

Exporting variables: 


Bash

maira040@ubuntu64:~$ export DB_URL="postgres://db.example.local:5432/mydb"
maira040@ubuntu64:~$ export DB_USER="labuser"
maira040@ubuntu64:~$ export DB_PASSWORD="labpass123"
Displaying variables with echo:


echo "$DB_URL" → postgres://db.example.local:5432/mydb 




echo "$DB_USER" → labuser 



echo "$DB_PASSWORD" → labpass123 



Filtering variables with printenv | grep '^DB_':


DB_PASSWORD=labpass123 


DB_USER=labuser 


DB_URL=postgres://db.example.local:5432/mydb 

Task 3: Make DB_* variables persistent in ~/.bashrc

Adding export commands to ~/.bashrc: The following lines were added: 


Bash

export DB_URL="postgres://db.example.local:5432/mydb"
export DB_USER="labuser"
export DB_PASSWORD="labpass 123"

Sourcing ~/.bashrc and checking variables: 



source ~/.bashrc 



echo "$DB_URL" → postgres://db.example.local:5432/mydb 



echo "$DB_USER" → labuser 


echo "$DB_PASSWORD" → labpass123 


printenv | grep '^DB_' output confirms the variables are set.

Task 4: System-wide environment variable, welcome script, and PATH

Checking /etc/environment: 

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"
Class="CC-5thB"
[cite: 68, 71, 73]

Checking $PATH and Class:


echo "$PATH" → /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin 



Upon a new login, the Class variable is echoed: CC 5thB.



Creating a welcome script (~/welcome): 

Bash

#!/bin/bash
echo "Welcome to Cloud Computing $USER"

Executing the script: 

./welcome → Welcome to Cloud Computing maira040

**Making the script executable from any path (after setting $PATH)**: The path variable was modified (implicitly or explicitly in ~/.bashrc with PATH=$PATH:\).



welcome → Welcome to Cloud Computing maira040 

Task 5: Block and allow SSH using ufw (firewall)

Enabling ufw and checking status: 


sudo ufw enable → Firewall is active and enabled on system startup 


sudo ufw status verbose shows Status: active and Default: deny (incoming).



Blocking SSH (port 22/tcp): 


sudo ufw deny 22/tcp → Rule added 


sudo ufw status numbered confirms DENY IN rules for 22/tcp and 22/tcp (v6).



Testing the block (Connection timed out): 

Attempting to SSH from a client: ssh maira040@192.168.238.129 → ssh: connect to host 192.168.238.129 port 22: Connection timed out


Allowing SSH (port 22/tcp): 


sudo ufw allow 22/tcp → Rule updated 


sudo ufw reload → Firewall reloaded 


sudo ufw status confirms ALLOW rules for 22/tcp and 22/tcp (v6).


Testing the allow (Successful connection): 

Attempting to SSH from a client: ssh maira040@192.168.238.129 → Successful connection, prompting for password.

Task 6: Configure SSH key-based login from Windows host

Generating SSH key pair: 


ssh-keygen -t ed25519 -f ~/.ssh/id_lab7 -C "lab_key" 

Private key saved to /home/maira040/.ssh/id_lab7 

Public key saved to /home/maira040/.ssh/id_lab7.pub 


Displaying the public key: 


cat $HOME/.ssh/id_lab7.pub → ssh-ed25519 AAAAC3NzaC11ZDI1NTE5AAAAIPteE/7Y4AutqGN+KB82dz7pVrvxMlAfNunde3tDVEFo lab_key 

Adding public key to authorized_keys:

The public key was appended to ~/.ssh/authorized_keys.

Permissions were set: chmod 700 ~/.ssh and chmod 600 ~/.ssh/authorized_keys.



Testing key-based login: 

Initial attempt required a password (not shown with key): ssh maira040@192.168.238.129.

Second attempt using the key specified: sshi ~/.ssh/id_lab7 maira040@192.168.238.129 (Note: the command is likely a typo for ssh -i) → Still prompted for password, likely the passphrase for the key.

Successful connection was achieved, leading to the Ubuntu welcome message.

EXAM EVALUATION QUESTIONS:
Question 1: Print environment variables and specific ones
Full printenv output (after Task 3): Includes environment variables like:


DB_PASSWORD=labpass123 


DB_USER=labuser 


DB_URL=postgres://db.example.local:5432/mydb 


Class CC-5thB 

Printing specific variables:


printenv PATH → /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/s 


printenv LANG → en_US.UTF-8 


printenv PWD → /home/maira040 

Question 2: Export STUDENT_* variables temporarily

Exporting variables: 

Bash

maira040@ubuntu64:~$ export STUDENT_NAME="Maira Malik"
maira040@ubuntu64:~$ export STUDENT_ROLL_NUMBER="040"
maira040@ubuntu64:~$ export STUDENT_SEMESTER="5th"
Displaying variables with echo:


echo $STUDENT NAME → Maira Malik 



echo $STUDENT_ROLL_NUMBER → 040 


echo $STUDENT_SEMESTER → 5th 

Filtering variables with printenv | grep STUDENT_:


STUDENT NAME Maira Malik 


STUDENT_SEMESTER $=5+h$ 


STUDENT ROLL_NUMBER $=040$ 

Question 3: Make STUDENT_* variables persistent in ~/.bashrc

Adding export commands to ~/.bashrc: 



Bash

export STUDENT_NAME="Maira Malik"
export STUDENT_ROLL_NUMBER="040"
export STUDENT_SEMESTER="5th"
Sourcing ~/.bashrc and checking variables:


source ~/.bashrc 


echo $STUDENT_NAME → Maira Malik 


printenv | grep ' STUDENT_ confirms the variables are set.

Checking variables after new login:

After a fresh login, echo $STUDENT NAME → Maira Malik.


printenv grep STUDENT confirms persistence.

Question 4: Block ICMP traffic using ufw

ufw status: Status: active with ALLOW rules for 22/tcp and 22/tcp (v6).




Attempting to block ICMP: 

sudo ufw deny proto icmp from any to any

Output: ERROR: Unsupported protocol 'icmp'  (Note: ufw handles ICMP differently; typically, it's controlled by default policies or modules, not this direct syntax).


Testing ping: 


ping 192.168.238.129 → Successful ping with low latency times (e.g., time=0.102 ms). This indicates that ICMP traffic was not blocked despite the failed ufw command.
