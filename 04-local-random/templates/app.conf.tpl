# Конфигурация ${app_name}
# Окружение: ${environment}
# Генерировано Terraform — не редактировать вручную

[app]
name    = ${app_name}-${suffix}
env     = ${environment}
db_host = ${db_host}
db_port = 5432
log_level = info