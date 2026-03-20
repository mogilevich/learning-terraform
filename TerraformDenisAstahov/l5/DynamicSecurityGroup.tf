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

    user_data = templatefile("${path.module}/user_data.sh.tpl", {
        f_name = "Aleksandr",
        l_name = "Mogilevich",
        names = ["asd", "zxc", "qwe", "rty", "fgh", "vbn", "cvb", "dfg", "hjk", "mnb"],
        webserver_port = 80
    })
    tags = {
      Name = "My Web Server"
    }
}

resource "aws_security_group" "my_webserver_sg" {
    name        = "my_webserver_sg"
    description = "Dynamic Security Group for Web Server"

    dynamic "ingress" {
        for_each = ["80", "443", "8080", "8443"]
        content {
                from_port   = ingress.value
                to_port     = ingress.value
                protocol    = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["10.20.30.40/32"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "Web Server Dynamic SG"
    }
}