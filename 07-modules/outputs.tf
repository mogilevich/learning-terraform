# ------------------------------------------------------------
# Outputs корневого модуля — используем outputs дочерних модулей
# Доступ: module.<имя_модуля>.<output_модуля>
# ------------------------------------------------------------

output "web_container_name" {
  description = "Имя web-контейнера"
  value       = module.web.container_name
}

output "api_container_name" {
  description = "Имя api-контейнера"
  value       = module.api.container_name
}

output "web_url" {
  value = "http://localhost:${module.web.external_port}"
}

output "api_url" {
  value = "http://localhost:${module.api.external_port}"
}
