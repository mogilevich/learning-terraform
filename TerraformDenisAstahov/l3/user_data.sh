#!/bin/bash
yum install -y httpd
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 60")
MY_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)
echo "<h1>My IP: $MY_IP</h1> Using external script" > /var/www/html/index.html
systemctl start httpd
systemctl enable httpd