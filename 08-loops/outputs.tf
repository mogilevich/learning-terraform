# ============================================================
# Outputs с циклами
# ============================================================

# splat-выражение [*] — собрать атрибут со всех экземпляров count
# Аналог: map(attribute, list) в Ansible
output "web_names" {
  description = "Имена всех web-контейнеров (count)"
  value       = docker_container.web[*].name
  # → ["web-dev-0", "web-dev-1", "web-dev-2"]
}

output "web_ports" {
  description = "Порты всех web-контейнеров"
  value       = [for c in docker_container.web : c.ports[0].external]
  # → [8090, 8091, 8092]
}

# for_each возвращает map — ключи те же что в for_each
output "service_ports" {
  description = "Порты всех сервисов (for_each) — map"
  value       = { for k, v in docker_container.service : k => v.ports[0].external }
  # → {"web" = 8080, "api" = 8081, "admin" = 8082}
}

output "service_tokens" {
  description = "Токены сервисов"
  value       = { for k, v in random_string.token : k => v.result }
  sensitive   = true
}
