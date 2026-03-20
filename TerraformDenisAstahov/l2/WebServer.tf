#
# My TF
# build web server during bootstrap
# 
provider "aws" {
    profile = "default"
    region = "eu-central-1"
}

resource "aws_instance" "my_webserver" {
    ami                    = "ami-0cf4768e2f1e520c5" # Amazon Linux 2023 eu-central-1
    instance_type          = "t3.micro"
    vpc_security_group_ids = [aws_security_group.my_webserver_sg.id]

    user_data = <<-EOF
#!/bin/bash
yum install -y httpd
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 60")
MY_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)
echo "<h1>My IP: $MY_IP</h1>" > /var/www/html/index.html
systemctl start httpd
systemctl enable httpd
EOF

    tags = {
      Name = "My Web Server"
    }
}

resource "aws_security_group" "my_webserver_sg" {
    name        = "my_webserver_sg"
    description = "Allow HTTP and HTTPS traffic to web server"

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "Web Server SG"
    }
}