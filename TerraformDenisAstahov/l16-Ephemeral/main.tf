#----------------------------------------------------------
# My Terraform
#
# Ephemeral Resources Example
# Generate Password → Store in SSM → Read via Ephemeral → Use in RDS
#
# Ephemeral resources don't persist in state, so secrets
# never end up in terraform.tfstate
#----------------------------------------------------------
provider "aws" {
  region = "ca-central-1"
}

// Generate Password via Ephemeral — not stored in state
ephemeral "random_password" "rds_password" {
  length           = 12
  special          = true
  override_special = "!#$&"
}

// Store Password in SSM Parameter Store
resource "aws_ssm_parameter" "rds_password" {
  name        = "/prod/mysql"
  description = "Master Password for RDS MySQL"
  type        = "SecureString"
  value_wo         = ephemeral.random_password.rds_password.result
  value_wo_version = 1
}

// Get Password from SSM via Ephemeral — not stored in state
ephemeral "aws_ssm_parameter" "my_rds_password" {
  arn = aws_ssm_parameter.rds_password.arn
}

// Example of Use Password in RDS
resource "aws_db_instance" "default" {
  identifier           = "prod-rds"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = "prod"
  username             = "administrator"
  password_wo          = ephemeral.aws_ssm_parameter.my_rds_password.value
  password_wo_version  = aws_ssm_parameter.rds_password.version
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  apply_immediately    = true
}
