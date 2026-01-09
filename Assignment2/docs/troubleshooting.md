# Troubleshooting Guide

## Common Issues and Solutions

### 1. Terraform Issues

#### Issue: `terraform init` fails with provider errors

**Error Message**:
```
Error: Failed to query available provider packages
```

**Solutions**:
1. Check internet connectivity
2. Clear Terraform cache:
   ```bash
   rm -rf .terraform .terraform.lock.hcl
   terraform init
   ```
3. Use specific provider version:
   ```bash
   terraform init -upgrade
   ```

#### Issue: `terraform apply` fails with credential errors

**Error Message**:
```
Error: error configuring Terraform AWS Provider: no valid credential sources
```

**Solutions**:
1. Configure AWS credentials:
   ```bash
   aws configure
   ```
2. Check AWS credentials file:
   ```bash
   cat ~/.aws/credentials
   ```
3. Export credentials temporarily:
   ```bash
   export AWS_ACCESS_KEY_ID="your-access-key"
   export AWS_SECRET_ACCESS_KEY="your-secret-key"
   export AWS_DEFAULT_REGION="me-central-1"
   ```

#### Issue: AMI not found in region

**Error Message**:
```
Error: error reading AMI: AMI not found
```

**Solutions**:
1. Update AMI ID in `locals.tf` for your region:
   ```bash
   aws ec2 describe-images \
     --owners amazon \
     --filters "Name=name,Values=al2023-ami-*-x86_64" \
     --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' \
     --output text
   ```
2. Update the AMI ID in `locals.tf`

#### Issue: Resource already exists

**Error Message**:
```
Error: Resource already exists
```

**Solutions**:
1. Import existing resource:
   ```bash
   terraform import aws_vpc.main vpc-xxxxx
   ```
2. Or destroy and recreate:
   ```bash
   terraform destroy
   terraform apply
   ```

### 2. SSH Connection Issues

#### Issue: Permission denied (publickey)

**Error Message**:
```
Permission denied (publickey,gssapi-keyex,gssapi-with-mic)
```

**Solutions**:
1. Check key permissions:
   ```bash
   chmod 600 ~/.ssh/id_ed25519
   chmod 644 ~/.ssh/id_ed25519.pub
   ```
2. Verify correct key:
   ```bash
   ssh -i ~/.ssh/id_ed25519 -v ec2-user@<ip>
   ```
3. Check if key was uploaded:
   ```bash
   aws ec2 describe-key-pairs
   ```

#### Issue: Connection timeout

**Error Message**:
```
ssh: connect to host x.x.x.x port 22: Connection timed out
```

**Solutions**:
1. Check security group allows your IP:
   ```bash
   curl https://icanhazip.com  # Get your current IP
   ```
2. Update security group if IP changed:
   ```bash
   terraform apply -replace="module.security.aws_security_group.nginx"
   ```
3. Check instance is running:
   ```bash
   aws ec2 describe-instances --instance-ids i-xxxxx
   ```

#### Issue: Host key verification failed

**Error Message**:
```
Host key verification failed
```

**Solutions**:
1. Remove old host key:
   ```bash
   ssh-keygen -R <ip-address>
   ```
2. Or disable strict host checking (not recommended):
   ```bash
   ssh -o StrictHostKeyChecking=no ec2-user@<ip>
   ```

### 3. Nginx Issues

#### Issue: Nginx won't start

**Error Message**:
```
Job for nginx.service failed
```

**Debug Steps**:
1. Check nginx configuration:
   ```bash
   sudo nginx -t
   ```
2. Check error logs:
   ```bash
   sudo tail -50 /var/log/nginx/error.log
   ```
3. Check if port is in use:
   ```bash
   sudo netstat -tlnp | grep :443
   sudo netstat -tlnp | grep :80
   ```
4. Restart nginx:
   ```bash
   sudo systemctl stop nginx
   sudo systemctl start nginx
   ```

#### Issue: Can't connect to backend servers

**Error Message in logs**:
```
connect() failed (111: Connection refused) while connecting to upstream
```

**Solutions**:
1. Verify backend IPs in nginx config:
   ```bash
   sudo grep "server.*:80" /etc/nginx/nginx.conf
   ```
2. Test backend connectivity:
   ```bash
   curl -v http://<backend-private-ip>
   ```
3. Check security group allows traffic from Nginx
4. Verify backends are running:
   ```bash
   # On backend server
   sudo systemctl status httpd
   ```

#### Issue: SSL certificate errors

**Error Message**:
```
SSL: error:xxx
```

**Solutions**:
1. Regenerate certificate:
   ```bash
   sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
     -keyout /etc/ssl/private/selfsigned.key \
     -out /etc/ssl/certs/selfsigned.crt \
     -subj "/CN=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
   ```
2. Check certificate permissions:
   ```bash
   sudo chmod 600 /etc/ssl/private/selfsigned.key
   sudo chmod 644 /etc/ssl/certs/selfsigned.crt
   ```
3. Verify certificate:
   ```bash
   sudo openssl x509 -in /etc/ssl/certs/selfsigned.crt -text -noout
   ```

#### Issue: Cache not working

**Symptoms**: X-Cache-Status always shows MISS

**Solutions**:
1. Check cache directory exists and has correct permissions:
   ```bash
   sudo ls -la /var/cache/nginx/
   sudo chown -R nginx:nginx /var/cache/nginx
   sudo chmod -R 755 /var/cache/nginx
   ```
2. Create cache directory if missing:
   ```bash
   sudo mkdir -p /var/cache/nginx/data
   sudo mkdir -p /var/cache/nginx/temp
   sudo chown -R nginx:nginx /var/cache/nginx
   ```
3. Check nginx configuration:
   ```bash
   sudo nginx -t
   sudo grep -A 5 "proxy_cache_path" /etc/nginx/nginx.conf
   ```
4. Restart nginx:
   ```bash
   sudo systemctl restart nginx
   ```

### 4. Apache Issues

#### Issue: Apache won't start on backend servers

**Error Message**:
```
Job for httpd.service failed
```

**Debug Steps**:
1. Check Apache status:
   ```bash
   sudo systemctl status httpd
   ```
2. Check error logs:
   ```bash
   sudo tail -50 /var/log/httpd/error_log
   ```
3. Test configuration:
   ```bash
   sudo apachectl configtest
   ```
4. Check if port 80 is in use:
   ```bash
   sudo netstat -tlnp | grep :80
   ```
5. Restart Apache:
   ```bash
   sudo systemctl restart httpd
   ```

#### Issue: Cannot access backend server webpage

**Solutions**:
1. Verify Apache is running:
   ```bash
   sudo systemctl status httpd
   ```
2. Test locally on server:
   ```bash
   curl localhost
   ```
3. Check firewall (should be disabled on Amazon Linux 2023):
   ```bash
   sudo systemctl status firewalld
   ```
4. Check file permissions:
   ```bash
   sudo ls -la /var/www/html/index.html
   sudo chmod 644 /var/www/html/index.html
   ```

### 5. Network Issues

#### Issue: Cannot ping instances

**Note**: EC2 instances by default don't respond to ping (ICMP disabled)

**Solutions**:
1. Use HTTP/HTTPS instead:
   ```bash
   curl http://<ip>
   curl -k https://<ip>
   ```
2. Or allow ICMP in security group (optional):
   ```hcl
   ingress {
     from_port   = -1
     to_port     = -1
     protocol    = "icmp"
     cidr_blocks = ["<your-ip>/32"]
   }
   ```

#### Issue: Security group not working

**Debug Steps**:
1. Check security group rules:
   ```bash
   aws ec2 describe-security-groups --group-ids <sg-id>
   ```
2. Verify instance is using correct SG:
   ```bash
   aws ec2 describe-instances --instance-ids <instance-id> \
     --query 'Reservations[].Instances[].SecurityGroups'
   ```
3. Check your current IP:
   ```bash
   curl https://icanhazip.com
   ```

#### Issue: Instance has no public IP

**Solutions**:
1. Check subnet configuration:
   ```bash
   aws ec2 describe-subnets --subnet-ids <subnet-id>
   ```
2. Ensure `map_public_ip_on_launch = true` in subnet resource
3. Recreate instance:
   ```bash
   terraform taint module.nginx_server.aws_instance.server
   terraform apply
   ```

### 6. Load Balancing Issues

#### Issue: Traffic only going to one backend

**Debug Steps**:
1. Check nginx upstream configuration:
   ```bash
   sudo grep -A 5 "upstream backend_servers" /etc/nginx/nginx.conf
   ```
2. Monitor access logs:
   ```bash
   sudo tail -f /var/log/nginx/access.log
   ```
3. Verify all backends are healthy:
   ```bash
   # On each backend server
   sudo systemctl status httpd
   ```

#### Issue: Backup server is receiving traffic

**Cause**: Primary servers are down or failing health checks

**Solutions**:
1. Check primary server status:
   ```bash
   # On Nginx server
   sudo tail -50 /var/log/nginx/error.log
   ```
2. Test primary backends:
   ```bash
   curl http://<primary-backend-ip>
   ```
3. Restart Apache on primary servers:
   ```bash
   sudo systemctl restart httpd
   ```

### 7. Performance Issues

#### Issue: Slow response times

**Debug Steps**:
1. Check server load:
   ```bash
   top
   htop
   ```
2. Check nginx worker processes:
   ```bash
   ps aux | grep nginx
   ```
3. Check connection limits:
   ```bash
   sudo grep "worker_connections" /etc/nginx/nginx.conf
   ```
4. Monitor logs for errors:
   ```bash
   sudo tail -f /var/log/nginx/error.log
   ```

**Solutions**:
1. Increase worker connections
2. Enable caching (if not already)
3. Scale vertically (larger instance type)
4. Scale horizontally (more backend servers)

#### Issue: High memory usage

**Debug Steps**:
1. Check memory usage:
   ```bash
   free -h
   top
   ```
2. Check nginx cache size:
   ```bash
   sudo du -sh /var/cache/nginx/
   ```

**Solutions**:
1. Reduce cache size in nginx.conf
2. Clear cache:
   ```bash
   sudo rm -rf /var/cache/nginx/data/*
   sudo systemctl reload nginx
   ```
3. Upgrade to larger instance type

### 8. Monitoring and Debugging

#### Useful Commands

**Check all service statuses**:
```bash
# On Nginx server
sudo systemctl status nginx

# On backend servers
sudo systemctl status httpd
```

**Monitor logs in real-time**:
```bash
# Nginx access logs
sudo tail -f /var/log/nginx/access.log

# Nginx error logs
sudo tail -f /var/log/nginx/error.log

# Apache access logs
sudo tail -f /var/log/httpd/access_log

# Apache error logs
sudo tail -f /var/log/httpd/error_log
```

**Check network connections**:
```bash
# Active connections
sudo netstat -tlnp

# Nginx connections
sudo netstat -tlnp | grep nginx

# Apache connections
sudo netstat -tlnp | grep httpd
```

**Test endpoints**:
```bash
# Test HTTPS
curl -k -v https://<nginx-ip>

# Test HTTP
curl -v http://<nginx-ip>

# Test health check
curl -k https://<nginx-ip>/health

# Test backend directly
curl http://<backend-public-ip>
```

**Check cache status**:
```bash
# View cache headers
curl -k -I https://<nginx-ip>

# Check cache directory
sudo ls -lah /var/cache/nginx/data/

# View cache statistics from logs
sudo grep "Cache:" /var/log/nginx/access.log | tail -20
```

### 9. Terraform State Issues

#### Issue: State file conflicts

**Error Message**:
```
Error: Error acquiring the state lock
```

**Solutions**:
1. Wait for lock to release (if another operation is running)
2. Force unlock (use with caution):
   ```bash
   terraform force-unlock <lock-id>
   ```

#### Issue: Resources exist but not in state

**Solutions**:
1. Import resources:
   ```bash
   terraform import aws_instance.example i-xxxxx
   ```
2. Or recreate with Terraform:
   ```bash
   # Delete manually from AWS Console
   # Then run
   terraform apply
   ```

### 10. Cleanup Issues

#### Issue: Resources not deleted

**Solutions**:
1. Delete manually from AWS Console
2. Remove from state:
   ```bash
   terraform state rm aws_instance.example
   ```
3. Force destroy:
   ```bash
   terraform destroy -auto-approve
   ```

#### Issue: Dependencies prevent deletion

**Solutions**:
1. Destroy in order:
   ```bash
   terraform destroy -target=module.webserver
   terraform destroy -target=module.security
   terraform destroy -target=module.networking
   ```

## Getting Help

### Log Collection

When reporting issues, collect:

1. **Terraform logs**:
   ```bash
   terraform plan 2>&1 | tee terraform-plan.log
   terraform apply 2>&1 | tee terraform-apply.log
   ```

2. **System logs**:
   ```bash
   sudo journalctl -u nginx -n 100 > nginx-service.log
   sudo journalctl -u httpd -n 100 > httpd-service.log
   ```

3. **Configuration files**:
   ```bash
   sudo cat /etc/nginx/nginx.conf > nginx-config.txt
   ```

### Support Resources

- [Terraform AWS Provider Issues](https://github.com/hashicorp/terraform-provider-aws/issues)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [AWS Forums](https://forums.aws.amazon.com/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/terraform)

## Best Practices to Avoid Issues

1. **Always test configuration**:
   ```bash
   terraform validate
   terraform plan
   sudo nginx -t
   ```

2. **Keep backups**:
   ```bash
   cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
   ```

3. **Use version control**:
   ```bash
   git commit -am "Update nginx configuration"
   ```

4. **Monitor logs regularly**:
   ```bash
   # Set up log monitoring
   sudo tail -f /var/log/nginx/error.log
   ```

5. **Document changes**:
   - Keep a changelog
   - Document custom configurations
   - Note any deviations from standard setup
