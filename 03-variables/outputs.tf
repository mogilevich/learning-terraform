# ============================================================
# Outputs — то, что Terraform выводит после apply
# ============================================================
#
# Аналогия в Ansible: debug + register
#   - name: Show container IP
#     debug:
#       msg: "{{ container_result.container.NetworkSettings.IPAddress }}"
#
# В Terraform outputs — это явно объявленные "возвращаемые значения".
# Они нужны для:
#   1. Показать информацию после apply (IP, URL, ID...)
#   2. Передать данные между модулями (как return values роли — урок 07)

output "container_name" {
  description = "Имя созданного контейнера"
  value       = docker_container.web.name
}

output "container_id" {
  description = "ID контейнера (короткий)"
  value       = substr(docker_container.web.id, 0, 12)
}

output "access_url" {
  description = "URL для доступа к nginx"
  value       = "http://localhost:${var.external_port}"
}

# Можно выводить любые вычисляемые выражения
output "all_labels" {
  description = "Все метки контейнера"
  value       = local.all_labels
}
