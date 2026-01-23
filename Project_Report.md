# Lab Project Report: Terraform + Ansible Roles - Nginx Frontend with 3 Backend HTTPD Servers (HA + Auto-Config)

**Student Name:** Maira Malik
**Roll Number:** 2023-BSE-040
**Date:** January 23, 2026  
**Repository:** CC_MairaMalik_040/LabProject_FrontendBackend  

---

## Table of Contents

1. [Introduction](#introduction)
2. [Project Overview](#project-overview)
3. [Learning Outcomes](#learning-outcomes)
4. [Architecture Requirements](#architecture-requirements)
5. [Implementation Details](#implementation-details)
   5.1 [Terraform Infrastructure](#terraform-infrastructure)
   5.2 [Ansible Configuration](#ansible-configuration)
   5.3 [Automation Integration](#automation-integration)
6. [Testing and Verification](#testing-and-verification)
7. [Code Quality and Documentation](#code-quality-and-documentation)
8. [Challenges and Solutions](#challenges-and-solutions)
9. [Conclusion](#conclusion)
10. [References](#references)

---

## 1. Introduction

This report documents the implementation of a comprehensive lab project that demonstrates the integration of Infrastructure as Code (IaC) using Terraform and configuration management with Ansible. The project creates a highly available (HA) web architecture featuring an Nginx load balancer frontend with three Apache HTTPD backend servers, where two serve as active nodes and one acts as a backup.

The project was developed in a GitHub Codespace environment with all necessary tools pre-installed, showcasing real-world DevOps practices for cloud infrastructure deployment and management.

---

## 2. Project Overview

### Project Scope
- **Duration:** 5-6 hours
- **Environment:** GitHub Codespace (Linux) with Terraform, AWS CLI, Python, and Ansible
- **Cloud Provider:** Amazon Web Services (AWS)
- **Infrastructure Components:**
  - 1 VPC with public subnet
  - 1 Nginx frontend EC2 instance
  - 3 Apache HTTPD backend EC2 instances
  - Security groups and networking components

### Technologies Used
- **Infrastructure as Code:** Terraform
- **Configuration Management:** Ansible
- **Cloud Platform:** AWS EC2, VPC, Security Groups
- **Web Servers:** Nginx (frontend), Apache HTTPD (backend)
- **Version Control:** Git

---

## 3. Learning Outcomes

By completing this project, the following competencies were demonstrated:

1. **Infrastructure Design:** Ability to design and implement a multi-tier AWS architecture using Terraform
2. **Ansible Roles:** Proper use of Ansible roles for separating responsibilities between frontend and backend configurations
3. **Load Balancing:** Implementation of Nginx as a reverse proxy with upstream configuration featuring 2 active + 1 backup servers
4. **Automation:** Integration of Terraform and Ansible for fully automated deployment
5. **HA Concepts:** Understanding and implementation of high availability through load balancing and failover mechanisms
6. **Production Practices:** Application of production-like code structure, documentation, and Git usage

---

## 4. Architecture Requirements

### Overall Topology
```
Internet
    │
    ▼
┌─────────────┐
│   Nginx     │  ← Frontend Load Balancer
│ (Port 80)   │
└─────┬───────┘
      │
   ┌──▼──┐
   │     │
┌──▼─┐ ┌─▼─┐ ┌──▼─┐
│HTTPD│ │HTTPD│ │HTTPD│
│Srv1 │ │Srv2 │ │Srv3 │  ← Backend Servers
└─────┘ └─────┘ └─────┘
   ▲       ▲       ▲
   │       │       │
   └─Active┼─Active┼─Backup
```

### Key Requirements
- **Frontend:** Nginx reverse proxy/load balancer
- **Backend:** 3 Apache HTTPD servers with distinct content
- **Load Balancing:** Round-robin between 2 active backends, 1 backup
- **Networking:** Single VPC with public subnet, SSH access from Codespace IP
- **Automation:** Single `terraform apply -auto-approve` command for full deployment

### Nginx Upstream Configuration
```nginx
upstream backend_servers {
    server backend1_private_ip:80;
    server backend2_private_ip:80;
    server backup_backend_private_ip:80 backup;
}
```

---

## 5. Implementation Details

### 5.1 Terraform Infrastructure

#### VPC and Networking
- **VPC:** CIDR block `10.0.0.0/16`
- **Subnet:** Public subnet `10.0.1.0/24` with auto-assign public IPs
- **Internet Gateway:** Attached to VPC for internet access
- **Route Table:** Default route `0.0.0.0/0` via IGW

#### Security Groups
```hcl
# SSH access from Codespace IP only
ingress {
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = [local.my_ip]
}

# HTTP access from anywhere
ingress {
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
```

#### EC2 Instances
- **AMI:** Amazon Linux 2 (`ami-0c02fb55956c7d316`)
- **Instance Type:** `t2.micro`
- **Key Pair:** Dynamically generated with random suffix
- **Tags:** Meaningful naming (`lab-frontend`, `lab-backend-0`, etc.)

#### Dynamic IP Detection
```hcl
data "http" "my_ip" {
  url = "https://icanhazip.com"
}

locals {
  my_ip = "${chomp(data.http.my_ip.response_body)}/32"
}
```

### 5.2 Ansible Configuration

#### Role Structure
```
ansible/roles/
├── backend/
│   ├── tasks/main.yml
│   ├── handlers/main.yml
│   └── templates/backend_index.html.j2
└── frontend/
    ├── tasks/main.yml
    ├── handlers/main.yml
    └── templates/nginx_frontend.conf.j2
```

#### Backend Role Tasks
- Install Apache HTTPD
- Enable and start service
- Deploy custom index page with server identification

#### Frontend Role Tasks
- Enable Nginx repository (Amazon Linux extras)
- Install Nginx
- Deploy upstream configuration
- Configure reverse proxy settings

#### Dynamic Backend IP Resolution
```yaml
vars:
  backend1_private_ip: "{{ hostvars[groups['backends'][0]].ansible_default_ipv4.address }}"
  backend2_private_ip: "{{ hostvars[groups['backends'][1]].ansible_default_ipv4.address }}"
  backup_backend_private_ip: "{{ hostvars[groups['backends'][2]].ansible_default_ipv4.address }}"
```

### 5.3 Automation Integration

#### Terraform-Ansible Integration
```hcl
resource "null_resource" "ansible_config" {
  triggers = {
    frontend_ip = aws_instance.frontend.public_ip
    backend_ips = join(",", [for b in aws_instance.backend : b.public_ip])
  }

  depends_on = [aws_instance.frontend, aws_instance.backend, local_file.hosts]

  provisioner "local-exec" {
    command = <<-EOT
      cd ansible
      ANSIBLE_CONFIG=ansible.cfg ansible-playbook -i inventory/hosts playbooks/site.yaml
    EOT
  }
}
```

#### Dynamic Inventory Generation
- Template-based inventory file creation
- Automatic population of public IPs
- SSH key configuration for Ansible

---

## 6. Testing and Verification

### Infrastructure Validation
- **Terraform Plan/Apply:** Successful creation of all AWS resources
- **Ansible Execution:** Error-free playbook runs
- **Service Status:** All web servers running and accessible

### Functional Testing Results

#### Backend Server Verification
| Server | Public IP | Private IP | Status |
|--------|-----------|------------|--------|
| Backend 1 | 3.236.177.215 | 10.0.1.197 | ✅ HTTPD Running |
| Backend 2 | 3.239.208.232 | 10.0.1.217 | ✅ HTTPD Running |
| Backend 3 | 34.237.144.87 | 10.0.1.126 | ✅ HTTPD Running |

#### Load Balancer Testing

**Normal Operation (Round-Robin):**
```
Request 1: Backend server: 3.236.177.215
Request 2: Backend server: 3.239.208.232
Request 3: Backend server: 3.236.177.215
Request 4: Backend server: 3.239.208.232
```

**Failover Testing (Primary Backends Stopped):**
```
Request 1: Backend server: 34.237.144.87
Request 2: Backend server: 34.237.144.87
Request 3: Backend server: 34.237.144.87
```

### Performance Metrics
- **Deployment Time:** ~2 minutes (infrastructure + configuration)
- **Uptime:** 100% for all services post-deployment
- **Response Time:** < 100ms for local testing

---

## 7. Code Quality and Documentation

### Directory Structure
```
LabProject_FrontendBackend/
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Input variables
├── outputs.tf                 # Output definitions
├── locals.tf                  # Local values and data sources
├── terraform.tfvars           # Variable values
├── .gitignore                 # Git ignore rules
├── README.md                  # Project documentation
├── modules/                   # Reusable Terraform modules
│   ├── subnet/
│   └── webserver/
└── ansible/                   # Ansible configuration
    ├── ansible.cfg
    ├── inventory/
    ├── playbooks/
    └── roles/
```

### Code Standards
- **Terraform:** Consistent formatting, meaningful variable names
- **Ansible:** YAML best practices, role-based organization
- **Documentation:** Comprehensive README with setup instructions
- **Git Usage:** Clean commit history, no sensitive data committed

### Security Considerations
- SSH access restricted to Codespace IP
- No hardcoded credentials in code
- Private keys not committed to repository
- Security groups follow principle of least privilege

---

## 8. Challenges and Solutions

### Challenge 1: SSH Key Management
**Problem:** Duplicate key pair names causing deployment failures
**Solution:** Implemented random suffix generation for unique key names

### Challenge 2: Nginx Installation on Amazon Linux
**Problem:** Nginx package not available in default repositories
**Solution:** Added amazon-linux-extras enable nginx1 before installation

### Challenge 3: Ansible Configuration in World-Writable Directory
**Problem:** Ansible ignoring config file due to directory permissions
**Solution:** Explicit ANSIBLE_CONFIG environment variable in provisioner

### Challenge 4: Dynamic Backend IP Resolution
**Problem:** Ansible needing private IPs for Nginx upstream configuration
**Solution:** Used hostvars to dynamically gather private IPs from inventory

---

## 9. Conclusion

This project successfully demonstrates a complete DevOps workflow for deploying a highly available web application infrastructure on AWS. The integration of Terraform and Ansible provides a robust, automated solution that meets all specified requirements.

### Key Achievements
✅ **Complete Infrastructure Automation:** Single command deployment  
✅ **High Availability:** Load balancing with automatic failover  
✅ **Production-Ready Code:** Modular, documented, and maintainable  
✅ **Security Best Practices:** Restricted access and no exposed credentials  
✅ **Scalable Architecture:** Easy to extend with additional backends  

### Skills Demonstrated
- Cloud infrastructure design and implementation
- Infrastructure as Code with Terraform
- Configuration management with Ansible
- Load balancing and high availability concepts
- Automation and CI/CD principles
- Troubleshooting and problem-solving

The project serves as a solid foundation for understanding modern cloud-native application deployment and can be extended for more complex scenarios involving databases, monitoring, and additional services.

---

## 10. References

1. Terraform Documentation: https://www.terraform.io/docs
2. Ansible Documentation: https://docs.ansible.com/
3. AWS EC2 User Guide: https://docs.aws.amazon.com/ec2/
4. Nginx Load Balancing: https://nginx.org/en/docs/http/load_balancing.html
5. Amazon Linux 2 Documentation: https://aws.amazon.com/amazon-linux-2/

---

**End of Report**

*Note: To generate a PDF from this Markdown file, use tools like Pandoc or online Markdown-to-PDF converters.*
