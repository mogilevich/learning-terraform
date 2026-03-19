output "app_suffix" {
  description = "Случайный суффикс (часть имён ресурсов)"
  value       = random_string.suffix.result
}

output "app_config_path" {
  description = "Путь к сгенерированному конфигу"
  value       = local_file.app_config.filename
}

# sensitive = true — значение скрыто в terraform output и plan.
# Получить: terraform output -raw db_password
output "db_password" {
  description = "Пароль БД (sensitive)"
  value       = random_password.db.result
  sensitive   = true
}

output "db_credentials_path" {
  description = "Путь к файлу с кредами"
  value       = local_sensitive_file.db_credentials.filename
}
