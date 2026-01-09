# Assignment 2 - Multi-Tier Web Infrastructure on AWS

## 📋 Project Overview

This project implements a production-ready, highly available multi-tier web infrastructure on AWS using Terraform Infrastructure as Code (IaC). The architecture includes an Nginx reverse proxy/load balancer with SSL/TLS termination, caching, and three backend Apache web servers with automatic failover capability.

### Key Features

- ✅ **Infrastructure as Code**: Complete Terraform modules for networking, security, and compute
- ✅ **High Availability**: Load balancing with backup server configuration
- ✅ **Security**: SSL/TLS encryption, security groups, IMDSv2
- ✅ **Performance**: Nginx caching and gzip compression
- ✅ **Scalability**: Modular design for easy expansion
- ✅ **Monitoring**: Comprehensive logging and health checks

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Internet                            │
│                     (Public Access)                         │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ HTTPS (443) / HTTP (80)
                         │
                    ┌────▼─────┐
                    │   IGW    │  Internet Gateway
                    └────┬─────┘
                         │
        ┌────────────────┴────────────────┐
        │         VPC (10.0.0.0/16)       │
        │                                 │
        │  ┌───────────────────────────┐  │
        │  │  Public Subnet            │  │
        │  │  (10.0.10.0/24)           │  │
        │  │                           │  │
        │  │  ┌─────────────────────┐  │  │
        │  │  │   Nginx Server      │  │  │
        │  │  │ (Load Balancer)     │  │  │
        │  │  │  - SSL/TLS          │  │  │
        │  │  │  - Caching          │  │  │
        │  │  │  - Reverse Proxy    │  │  │
        │  │  │  - Security Headers │  │  │
        │  │  └────────┬────────────┘  │  │
        │  │           │               │  │
        │  │  ┌────────┼────────┐      │  │
        │  │  │        │        │      │  │
        │  │  ▼        ▼        ▼      │  │
        │  │ ┌───┐   ┌───┐   ┌───┐    │  │
        │  │ │W-1│   │W-2│   │W-3│    │  │
        │  │ │ ⚡│   │ ⚡│   │💤 │    │  │
        │  │ └───┘   └───┘   └───┘    │  │
        │  │  ↑        ↑        ↑      │  │
        │  │  Primary Primary Backup   │  │
        │  │  (Active)(Active) (Standby)│ │
        │  └───────────────────────────┘  │
        └─────────────────────────────────┘

        Security Groups:
        ├── Nginx SG: 22 (your IP), 80, 443 (0.0.0.0/0)
        └── Backend SG: 22 (your IP), 80 (from Nginx SG only)
```

### Component Description

| Component | Purpose | Details |
|-----------|---------|---------|
| **VPC** | Network isolation | CIDR: 10.0.0.0/16 |
| **Public Subnet** | Internet-facing resources | CIDR: 10.0.10.0/24 |
| **Internet Gateway** | Internet connectivity | Routes traffic to/from internet |
| **Nginx Server** | Load balancer & reverse proxy | SSL termination, caching, load balancing |
| **Backend Servers** | Application tier | 3 Apache servers (2 primary, 1 backup) |
| **Security Groups** | Network firewall | Nginx SG and Backend SG |

## 🎯 Prerequisites

### Required Tools

- **Terraform** >= 1.0
- **AWS CLI** >= 2.0
- **SSH client**
- **Git**
- **curl** (for testing)

### AWS Account Setup

1. **AWS Account** with appropriate permissions:
   - EC2 full access
   - VPC full access
   - IAM permissions for resource creation

2. **AWS Credentials Configuration**:
   ```bash
   aws configure
   # Enter your AWS Access Key ID
   # Enter your AWS Secret Access Key
   # Enter your default region (e.g., me-central-1)
   # Enter default output format (json)
   ```

3. **SSH Key Pair**:
   ```bash
   # Generate ED25519 SSH key (recommended)
   ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "your_email@example.com"
   
   # Or RSA key (alternative)
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -C "your_email@example.com"
   ```

## 🚀 Deployment Instructions

### Step 1: Clone the Repository

```bash
git clone <your-repository-url>
cd Assignment2
```

### Step 2: Configure Variables

Create `terraform.tfvars` from the example:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:

```hcl
vpc_cidr_block    = "10.0.0.0/16"
subnet_cidr_block = "10.0.10.0/24"
availability_zone = "me-central-1a"      # Update to your AZ
env_prefix        = "prod"
instance_type     = "t3.micro"
public_key        = "~/.ssh/id_ed25519.pub"
private_key       = "~/.ssh/id_ed25519"
```

⚠️ **Important**: Update the `availability_zone` to match your AWS region!

### Step 3: Update AMI ID (if needed)

Check `locals.tf` and update the AMI ID for your region:

```bash
# Find latest Amazon Linux 2023 AMI for your region
aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=al2023-ami-*-x86_64" \
  --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' \
  --output text
```

Update the `ami_id` in `locals.tf` if different.

### Step 4: Initialize Terraform

```bash
terraform init
```

Expected output:
- Downloads required providers (AWS, HTTP)
- Initializes backend
- Prepares modules

### Step 5: Validate Configuration

```bash
terraform validate
```

Should output: `Success! The configuration is valid.`

### Step 6: Plan Deployment

```bash
terraform plan
```

Review the execution plan. You should see:
- 1 VPC
- 1 Subnet
- 1 Internet Gateway
- 1 Route Table
- 2 Security Groups
- 4 EC2 Instances (1 Nginx + 3 Backend)
- 4 Key Pairs

### Step 7: Deploy Infrastructure

```bash
terraform apply
```

Type `yes` when prompted. Deployment takes approximately 3-5 minutes.

### Step 8: Save Outputs

```bash
# View all outputs
terraform output

# Save outputs to JSON file
terraform output -json > outputs.json

# View specific output
terraform output configuration_guide
```

## 🔧 Nginx Configuration

After deployment, you must update Nginx with actual backend server IPs:

### Step 1: SSH into Nginx Server

```bash
# Get Nginx IP from outputs
NGINX_IP=$(terraform output -raw nginx_public_ip)

# SSH into Nginx server
ssh -i ~/.ssh/id_ed25519 ec2-user@$NGINX_IP
```

### Step 2: Edit Nginx Configuration

```bash
sudo vim /etc/nginx/nginx.conf
```

Find the `upstream backend_servers` block and replace placeholders:

```nginx
upstream backend_servers {
    # Update these with actual private IPs from terraform output
    server <web-1-private-ip>:80 max_fails=3 fail_timeout=30s;
    server <web-2-private-ip>:80 max_fails=3 fail_timeout=30s;
    server <web-3-private-ip>:80 backup;
    
    keepalive 32;
}
```

Get private IPs:
```bash
terraform output backend_servers_private_ips
```

### Step 3: Test and Restart

```bash
# Test configuration
sudo nginx -t

# If test passes, restart
sudo systemctl restart nginx

# Verify status
sudo systemctl status nginx
```

## 🧪 Testing

### 1. Test HTTPS Access

```bash
# Get Nginx IP
NGINX_IP=$(terraform output -raw nginx_public_ip)

# Test HTTPS (accept self-signed certificate warning)
curl -k https://$NGINX_IP

# Or open in browser
https://<nginx-ip>
```

### 2. Test Load Balancing

Reload the page multiple times and observe:
- Server hostname changes between web-1 and web-2
- web-3 is NOT served (it's backup only)

### 3. Test Caching

```bash
# First request (should be MISS)
curl -k -I https://$NGINX_IP | grep X-Cache-Status

# Second request (should be HIT)
curl -k -I https://$NGINX_IP | grep X-Cache-Status
```

### 4. Test HTTP to HTTPS Redirect

```bash
curl -I http://$NGINX_IP
# Should return 301 redirect to HTTPS
```

### 5. Test Health Check

```bash
curl -k https://$NGINX_IP/health
# Should return: "Nginx Load Balancer is healthy and running!"
```

### 6. Test High Availability (Backup Server)

```bash
# SSH into web-1 and stop Apache
WEB1_IP=$(terraform output -json backend_servers_info | jq -r '.["web-1"].public_ip')
ssh -i ~/.ssh/id_ed25519 ec2-user@$WEB1_IP
sudo systemctl stop httpd

# Reload Nginx page - should only show web-2

# SSH into web-2 and stop Apache
WEB2_IP=$(terraform output -json backend_servers_info | jq -r '.["web-2"].public_ip')
ssh -i ~/.ssh/id_ed25519 ec2-user@$WEB2_IP
sudo systemctl stop httpd

# Reload Nginx page - should now show web-3 (backup activated!)

# Restart services
sudo systemctl start httpd
```

### 7. Monitor Logs

On Nginx server:

```bash
# Monitor access logs
sudo tail -f /var/log/nginx/access.log

# View cache statistics
sudo grep "Cache:" /var/log/nginx/access.log | tail -20

# Monitor error logs
sudo tail -f /var/log/nginx/error.log
```

## 📊 Monitoring and Logs

### Log Locations

| Log Type | Location | Purpose |
|----------|----------|---------|
| Nginx Access | `/var/log/nginx/access.log` | HTTP requests, cache status |
| Nginx Error | `/var/log/nginx/error.log` | Errors, backend failures |
| Apache Access | `/var/log/httpd/access_log` | Backend requests |
| Apache Error | `/var/log/httpd/error_log` | Backend errors |

### Useful Commands

```bash
# View cache directory
ls -lah /var/cache/nginx/data

# Check Nginx process
ps aux | grep nginx

# Test backend servers directly
curl http://<backend-public-ip>

# Check security group rules
aws ec2 describe-security-groups --group-ids <sg-id>
```

## 🔒 Security Features

1. **SSL/TLS Encryption**
   - HTTPS only (HTTP redirects to HTTPS)
   - TLS 1.2 and 1.3 support
   - Strong cipher suites

2. **Network Security**
   - Isolated VPC
   - Security groups with minimal access
   - Backend servers only accessible from Nginx
   - SSH limited to your IP

3. **Security Headers**
   - HSTS (HTTP Strict Transport Security)
   - X-Frame-Options
   - X-Content-Type-Options
   - X-XSS-Protection

4. **Instance Security**
   - IMDSv2 required
   - Encrypted root volumes
   - Latest Amazon Linux 2023

## 📁 Project Structure

```
Assignment2/
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output definitions
├── locals.tf                  # Local values and data sources
├── terraform.tfvars.example   # Example variables file
├── .gitignore                 # Git ignore rules
│
├── modules/
│   ├── networking/            # VPC, Subnet, IGW, Route Table
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── security/              # Security Groups
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── webserver/             # EC2 Instances
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── scripts/
│   ├── nginx-setup.sh         # Nginx installation & configuration
│   └── apache-setup.sh        # Apache installation & configuration
│
├── screenshots/               # Screenshots for assignment submission
│   ├── part1/
│   ├── part2/
│   ├── part3/
│   ├── part4/
│   ├── part5/
│   ├── part6/
│   └── bonus/
│
├── docs/
│   ├── architecture.md        # Detailed architecture documentation
│   └── troubleshooting.md     # Common issues and solutions
│
└── README.md                  # This file
```

## 🐛 Troubleshooting

### Issue: Terraform init fails

**Solution**:
```bash
# Clear Terraform cache
rm -rf .terraform .terraform.lock.hcl

# Re-initialize
terraform init
```

### Issue: SSH connection refused

**Solutions**:
1. Check security group allows your IP
2. Verify instance is running: `aws ec2 describe-instances`
3. Check SSH key permissions: `chmod 600 ~/.ssh/id_ed25519`

### Issue: Nginx can't connect to backends

**Solutions**:
1. Verify backend IPs are correct in Nginx config
2. Check backend servers are running: `sudo systemctl status httpd`
3. Verify security group allows traffic from Nginx

### Issue: SSL certificate warning

**Expected**: Self-signed certificates will show warnings. Click "Advanced" → "Proceed" in browser.

**For Production**: Use Let's Encrypt or AWS Certificate Manager.

### Issue: Cache not working

**Check**:
```bash
# Verify cache directory exists
ls -la /var/cache/nginx/

# Check permissions
sudo chown -R nginx:nginx /var/cache/nginx

# Check Nginx config
sudo nginx -t
```

### Issue: Backend server not responding

**Debug**:
```bash
# On backend server
sudo systemctl status httpd
sudo tail -f /var/log/httpd/error_log

# Test locally
curl localhost

# Restart Apache
sudo systemctl restart httpd
```

### Issue: Terraform apply hangs

**Solution**:
```bash
# Cancel (Ctrl+C) and check
aws ec2 describe-instances --filters "Name=tag:Project,Values=Assignment-2"

# If partially created, destroy and retry
terraform destroy
terraform apply
```

## 🗑️ Cleanup

To destroy all resources:

```bash
# Preview what will be destroyed
terraform plan -destroy

# Destroy infrastructure
terraform destroy

# Type 'yes' when prompted
```

Verify cleanup in AWS Console:
- EC2 Instances deleted
- Security Groups deleted
- Subnet deleted
- VPC deleted
- Key Pairs deleted

## 📚 Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [AWS VPC User Guide](https://docs.aws.amazon.com/vpc/)
- [Amazon Linux 2023 User Guide](https://docs.aws.amazon.com/linux/al2023/)

## 👤 Author

**Your Name**  
Roll Number: Your Roll Number  
Course: Cloud Computing  
Assignment: 2 - Multi-Tier Web Infrastructure

## 📝 License

This project is created for educational purposes as part of a Cloud Computing course assignment.

## 🙏 Acknowledgments

- AWS for cloud infrastructure
- Terraform for IaC capabilities
- Nginx for powerful reverse proxy features
- Apache HTTP Server for reliable web serving

---

**Note**: This is a production-ready infrastructure template. For actual production use, consider:
- Using AWS Certificate Manager for SSL
- Implementing proper DNS with Route 53
- Adding CloudWatch monitoring
- Implementing auto-scaling
- Using RDS for database tier
- Adding CloudFront CDN
- Implementing proper backup strategies
