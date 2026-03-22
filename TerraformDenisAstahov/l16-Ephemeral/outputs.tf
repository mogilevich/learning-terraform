output "rds_endpoint" {
  value = aws_db_instance.default.endpoint
}

output "ssm_parameter_arn" {
  value = aws_ssm_parameter.rds_password.arn
}
