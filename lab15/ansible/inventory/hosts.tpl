[frontend]
${frontend_ip}

[backends]
${backend_ips}

[all:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=${private_key}