# Architecture Documentation

## Overview

This document provides detailed architectural information about the multi-tier web infrastructure deployed on AWS.

## Network Architecture

### VPC Design

- **CIDR Block**: 10.0.0.0/16 (65,536 IP addresses)
- **DNS Resolution**: Enabled
- **DNS Hostnames**: Enabled

### Subnet Configuration

- **Public Subnet**: 10.0.10.0/24 (256 IP addresses)
- **Type**: Public (map_public_ip_on_launch = true)
- **Availability Zone**: Configurable (default: me-central-1a)
- **Purpose**: Hosts all EC2 instances with direct internet access

### Internet Connectivity

- **Internet Gateway**: Provides internet access for VPC resources
- **Route Table**: Default route (0.0.0.0/0) points to IGW
- **Association**: Route table associated with public subnet

## Security Architecture

### Security Groups

#### Nginx Security Group

**Purpose**: Protect load balancer/reverse proxy

**Inbound Rules**:
- SSH (22): From your public IP only
- HTTP (80): From anywhere (0.0.0.0/0)
- HTTPS (443): From anywhere (0.0.0.0/0)

**Outbound Rules**:
- All traffic (0-65535): To anywhere (0.0.0.0/0)

#### Backend Security Group

**Purpose**: Protect backend web servers

**Inbound Rules**:
- SSH (22): From your public IP only
- HTTP (80): From Nginx security group only

**Outbound Rules**:
- All traffic (0-65535): To anywhere (0.0.0.0/0)

### Security Features

1. **Network Isolation**
   - Backend servers only accept HTTP from Nginx
   - No direct public access to backend servers
   - SSH access restricted to administrator IP

2. **Instance Security**
   - IMDSv2 required (prevents SSRF attacks)
   - Encrypted EBS volumes
   - Latest Amazon Linux 2023 with security updates

3. **SSL/TLS**
   - Self-signed certificate for testing
   - TLS 1.2 and 1.3 support
   - Strong cipher suites
   - HTTP to HTTPS redirect

## Compute Architecture

### Instance Configuration

| Instance Type | Role | Count | Specs |
|---------------|------|-------|-------|
| t3.micro | Nginx Load Balancer | 1 | 2 vCPU, 1 GB RAM |
| t3.micro | Backend Web Server | 3 | 2 vCPU, 1 GB RAM |

### Storage

- **Type**: GP3 (General Purpose SSD)
- **Size**: 8 GB per instance
- **Encryption**: Enabled
- **Delete on Termination**: Yes

### Operating System

- **AMI**: Amazon Linux 2023
- **Architecture**: x86_64
- **Virtualization**: HVM

## Load Balancing Strategy

### Nginx Configuration

**Load Balancing Method**: Round-robin (default)

**Algorithm**: Distributes requests sequentially to each backend server

**Server Pool**:
```nginx
upstream backend_servers {
    server web-1:80 max_fails=3 fail_timeout=30s;
    server web-2:80 max_fails=3 fail_timeout=30s;
    server web-3:80 backup;
    keepalive 32;
}
```

### High Availability

1. **Primary Servers**: web-1 and web-2
   - Actively receive traffic
   - Round-robin distribution
   - Health checked every request

2. **Backup Server**: web-3
   - Only receives traffic when both primaries fail
   - Automatic failover
   - No manual intervention required

3. **Health Checks**:
   - max_fails: 3 (mark unhealthy after 3 failures)
   - fail_timeout: 30s (retry after 30 seconds)

### Traffic Flow

```
User Request → Nginx (HTTPS:443)
    ↓
SSL Termination
    ↓
Cache Check (HIT → Return cached)
    ↓
Cache MISS → Load Balancer
    ↓
Round-Robin Selection
    ↓
    ├→ web-1:80 (50% probability)
    └→ web-2:80 (50% probability)
    
If both fail:
    ↓
    └→ web-3:80 (backup)
```

## Caching Architecture

### Cache Configuration

**Type**: Nginx proxy cache

**Configuration**:
```nginx
proxy_cache_path /var/cache/nginx/data 
                 levels=1:2 
                 keys_zone=my_cache:10m 
                 max_size=1g 
                 inactive=60m 
                 use_temp_path=off;
```

**Parameters**:
- **levels=1:2**: Two-level directory hierarchy
- **keys_zone=my_cache:10m**: 10MB memory for cache keys (~80,000 keys)
- **max_size=1g**: Maximum 1GB disk cache
- **inactive=60m**: Remove cached items not accessed in 60 minutes

### Cache Behavior

1. **Cache Key**: `$scheme$request_method$host$request_uri`
2. **Valid Times**:
   - 200/302: 60 minutes
   - 404: 10 minutes
   - Other: 5 minutes

3. **Cache Headers**:
   - `X-Cache-Status`: MISS/HIT/BYPASS/EXPIRED
   - `X-Proxy-Cache`: Same as above

## Performance Optimization

### Nginx Optimizations

1. **Worker Processes**: Auto (matches CPU cores)
2. **Worker Connections**: 1024 per worker
3. **Keepalive**: 65 seconds
4. **Sendfile**: Enabled
5. **TCP Nopush**: Enabled
6. **TCP Nodelay**: Enabled

### Compression

**Gzip Configuration**:
- **Level**: 6 (balanced compression)
- **Types**: text/plain, text/css, application/json, application/javascript
- **Min Length**: Default (20 bytes)
- **Vary Header**: Added

### Connection Management

**Backend Keepalive**:
- 32 persistent connections to backends
- Reduces connection overhead
- Improves response time

## Monitoring and Logging

### Log Locations

**Nginx**:
- Access: `/var/log/nginx/access.log`
- Error: `/var/log/nginx/error.log`

**Apache (Backend)**:
- Access: `/var/log/httpd/access_log`
- Error: `/var/log/httpd/error_log`

### Log Format

**Nginx Access Log**:
```
$remote_addr - $remote_user [$time_local] "$request" 
$status $body_bytes_sent "$http_referer" 
"$http_user_agent" Cache: $upstream_cache_status
```

Includes:
- Client IP
- Timestamp
- Request details
- Response status
- Cache status

## Scalability Considerations

### Horizontal Scaling

**Current Setup**: 3 backend servers (2 active, 1 backup)

**Scaling Options**:
1. Add more primary servers to upstream block
2. Convert backup to primary for more capacity
3. Use Terraform count/for_each to deploy more instances

**Example**:
```hcl
locals {
  backend_servers = [
    {name = "web-1", suffix = "1"},
    {name = "web-2", suffix = "2"},
    {name = "web-3", suffix = "3"},
    {name = "web-4", suffix = "4"},  # New server
    {name = "web-5", suffix = "5"},  # New server
  ]
}
```

### Vertical Scaling

**Current**: t3.micro (2 vCPU, 1 GB RAM)

**Options**:
- t3.small (2 vCPU, 2 GB RAM)
- t3.medium (2 vCPU, 4 GB RAM)
- t3.large (2 vCPU, 8 GB RAM)

**To Scale**:
Update `instance_type` variable in `terraform.tfvars`

## High Availability Patterns

### Current Pattern: Active-Active with Backup

**Design**:
- 2 primary servers handling traffic
- 1 backup server for failover
- Automatic health checks
- Instant failover

**Advantages**:
- No single point of failure
- Automatic recovery
- No manual intervention
- Cost-effective

**Limitations**:
- Single AZ deployment
- No geographic redundancy

### Future Improvements

1. **Multi-AZ Deployment**:
   - Deploy across multiple availability zones
   - Higher availability
   - Zone failure resilience

2. **Auto Scaling**:
   - EC2 Auto Scaling Groups
   - Automatic capacity adjustment
   - Based on metrics (CPU, requests)

3. **Load Balancer Options**:
   - AWS Application Load Balancer (ALB)
   - Managed service
   - Advanced routing
   - Better health checks

4. **Database Tier**:
   - RDS for database
   - Read replicas
   - Automated backups

## Disaster Recovery

### Current Backup Strategy

**Infrastructure as Code**:
- All infrastructure defined in Terraform
- Can be recreated in minutes
- Version controlled

**Data Backup**:
- Stateless application (no persistent data)
- Can be redeployed without data loss

### Recovery Procedures

**Complete Infrastructure Loss**:
1. Run `terraform apply`
2. Update Nginx configuration
3. Infrastructure restored in ~5 minutes

**Single Server Failure**:
1. Automatic failover (no action needed)
2. Or: `terraform taint` and `terraform apply`

## Cost Optimization

### Current Monthly Cost (Estimate)

**Compute** (4 × t3.micro):
- On-Demand: ~$30/month
- 1-Year Reserved: ~$18/month
- 3-Year Reserved: ~$11/month

**Storage** (4 × 8GB GP3):
- ~$3.20/month

**Data Transfer**:
- First 1GB free
- Next 10TB: $0.09/GB

**Total Estimated**: $35-40/month (on-demand)

### Optimization Strategies

1. **Reserved Instances**: Save up to 40%
2. **Spot Instances**: Save up to 90% (for non-critical)
3. **Right-sizing**: Monitor and adjust instance types
4. **Auto Scaling**: Scale down during low traffic
5. **Data Transfer**: Use CloudFront CDN

## Security Best Practices

### Implemented

✅ Network isolation with VPC  
✅ Security groups with minimal access  
✅ SSL/TLS encryption  
✅ SSH key-based authentication  
✅ IMDSv2 for instance metadata  
✅ Encrypted EBS volumes  
✅ Security headers (HSTS, X-Frame-Options)  
✅ Latest OS with security updates  

### Recommended for Production

- [ ] AWS Certificate Manager for SSL
- [ ] WAF (Web Application Firewall)
- [ ] AWS Shield for DDoS protection
- [ ] CloudTrail for audit logging
- [ ] GuardDuty for threat detection
- [ ] Secrets Manager for credentials
- [ ] Systems Manager for patching
- [ ] CloudWatch for monitoring
- [ ] SNS for alerting

## Compliance Considerations

### Data Residency

- All resources in specified region
- No cross-region replication
- Meets data sovereignty requirements

### Encryption

- Data at rest: EBS encryption
- Data in transit: TLS 1.2/1.3
- Meets compliance requirements

### Access Control

- SSH keys for authentication
- No password-based access
- IP-restricted SSH access
- Role-based security groups

## Technology Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| IaC | Terraform | >= 1.0 |
| Cloud | AWS | N/A |
| OS | Amazon Linux | 2023 |
| Load Balancer | Nginx | Latest |
| Web Server | Apache | 2.4+ |
| SSL/TLS | OpenSSL | Latest |
| Protocol | HTTP/2 | N/A |

## References

- [AWS VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-best-practices.html)
- [Nginx Load Balancing](https://docs.nginx.com/nginx/admin-guide/load-balancer/http-load-balancer/)
- [Nginx Caching Guide](https://docs.nginx.com/nginx/admin-guide/content-cache/content-caching/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
