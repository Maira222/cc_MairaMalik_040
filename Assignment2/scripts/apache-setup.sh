#!/bin/bash
set -e

# Update system packages
echo "Updating system packages..."
yum update -y

# Install Apache HTTP Server
echo "Installing Apache HTTP Server..."
yum install httpd -y

# Start and enable Apache service
echo "Starting Apache service..."
systemctl start httpd
systemctl enable httpd

# Get metadata token (IMDSv2)
echo "Fetching instance metadata..."
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# Get instance metadata
PRIVATE_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/local-ipv4)
PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/public-ipv4)
PUBLIC_DNS=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/public-hostname)
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-id)
HOSTNAME=$(hostname)

# Set hostname
hostnamectl set-hostname myapp-webserver

# Create custom HTML page
echo "Creating custom HTML page..."
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Backend Web Server - Assignment 2</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        
        .container {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            padding: 40px;
            border-radius: 20px;
            box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
            border: 1px solid rgba(255, 255, 255, 0.18);
            max-width: 800px;
            width: 100%;
        }
        
        h1 {
            color: #fff;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
            margin-bottom: 30px;
            font-size: 2.5em;
            text-align: center;
        }
        
        .emoji {
            font-size: 1.2em;
            margin-right: 10px;
        }
        
        .info {
            margin: 15px 0;
            padding: 15px 20px;
            background: rgba(255,255,255,0.2);
            border-radius: 10px;
            border-left: 4px solid #ffd700;
            transition: all 0.3s ease;
        }
        
        .info:hover {
            background: rgba(255,255,255,0.3);
            transform: translateX(5px);
        }
        
        .label {
            font-weight: bold;
            color: #ffd700;
            display: inline-block;
            min-width: 150px;
        }
        
        .value {
            color: #fff;
            font-family: 'Courier New', monospace;
        }
        
        .status-badge {
            display: inline-block;
            padding: 5px 15px;
            background: #4CAF50;
            border-radius: 20px;
            font-weight: bold;
            color: white;
            box-shadow: 0 2px 5px rgba(0,0,0,0.2);
        }
        
        .footer {
            text-align: center;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid rgba(255,255,255,0.3);
            font-size: 0.9em;
            color: rgba(255,255,255,0.8);
        }
        
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.7; }
        }
        
        .pulse {
            animation: pulse 2s infinite;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1><span class="emoji">🚀</span>Backend Web Server<span class="emoji">🚀</span></h1>
        <h2 style="text-align: center; margin-bottom: 30px; color: #ffd700;">Assignment 2 - Multi-Tier Infrastructure</h2>
        
        <div class="info">
            <span class="label"><span class="emoji">🖥️</span>Hostname:</span>
            <span class="value">$HOSTNAME</span>
        </div>
        
        <div class="info">
            <span class="label"><span class="emoji">🆔</span>Instance ID:</span>
            <span class="value">$INSTANCE_ID</span>
        </div>
        
        <div class="info">
            <span class="label"><span class="emoji">🔒</span>Private IP:</span>
            <span class="value">$PRIVATE_IP</span>
        </div>
        
        <div class="info">
            <span class="label"><span class="emoji">🌍</span>Public IP:</span>
            <span class="value">$PUBLIC_IP</span>
        </div>
        
        <div class="info">
            <span class="label"><span class="emoji">📡</span>Public DNS:</span>
            <span class="value">$PUBLIC_DNS</span>
        </div>
        
        <div class="info">
            <span class="label"><span class="emoji">📅</span>Deployed:</span>
            <span class="value">$(date '+%Y-%m-%d %H:%M:%S %Z')</span>
        </div>
        
        <div class="info">
            <span class="label"><span class="emoji">✅</span>Status:</span>
            <span class="status-badge pulse">Active and Running</span>
        </div>
        
        <div class="info">
            <span class="label"><span class="emoji">⚙️</span>Managed By:</span>
            <span class="value">Terraform IaC</span>
        </div>
        
        <div class="info">
            <span class="label"><span class="emoji">🌐</span>Web Server:</span>
            <span class="value">Apache HTTP Server</span>
        </div>
        
        <div class="footer">
            <p>🔧 Infrastructure as Code | 🏗️ AWS Cloud | 🔄 Load Balanced</p>
            <p style="margin-top: 10px;">Powered by Terraform & AWS EC2</p>
        </div>
    </div>
</body>
</html>
EOF

# Set proper permissions
chmod 644 /var/www/html/index.html
chown apache:apache /var/www/html/index.html

# Restart Apache to apply changes
systemctl restart httpd

# Verify Apache is running
if systemctl is-active --quiet httpd; then
    echo "✅ Apache setup completed successfully!"
    echo "Server is ready to serve traffic"
else
    echo "❌ Apache setup failed!"
    exit 1
fi
