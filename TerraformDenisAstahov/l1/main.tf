provider "aws" {
    profile = "default"
    region = "eu-central-1"
}

resource "aws_instance" "my_ubuntu" {
    # count = 2
    ami = "ami-0e7c42697f755b023" # Ubuntu 24.04 LTS eu-central-1
    instance_type = "t3.micro"
    tags = {
      Name = "My ubuntu server"
      Owner = "Aleksandr"
      Project = "Terraform"
    }
}

resource "aws_instance" "my_amazon_linux" {
    ami           = "ami-0cf4768e2f1e520c5" # Amazon Linux 2023 eu-central-1
    instance_type = "t3.small"
    tags = {
      Name = "My AMZ server"
      Owner = "Aleksandr"
      Project = "Terraform"
    }
}

# resource "aws_default_vpc" "default" {
# }
# 
# resource "aws_security_group" "my_group" {
#     name = "my_security_group"
#     description = "Allow SSH and HTTP"
#     vpc_id = aws_default_vpc.default.id
# }