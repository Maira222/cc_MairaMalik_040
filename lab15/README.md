# Lab Project: Frontend Backend with Nginx HA

This project sets up a multi-tier AWS architecture using Terraform and Ansible.

## How to run

1. Ensure you have AWS credentials configured.
2. Update `terraform.tfvars` with your SSH public key.
3. Run `terraform init`
4. Run `terraform apply -auto-approve`

This will create the infrastructure and automatically configure the servers with Ansible.

## Assumptions

- Region: us-east-1
- AMI: Amazon Linux 2 (ami-0c02fb55956c7d316)
- Instance type: t2.micro
- SSH key: Provide your public key in terraform.tfvars