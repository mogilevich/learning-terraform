# ============================================================
# Outputs модуля — его "возвращаемые значения"
# Аналог: register в Ansible — что модуль возвращает наружу
#
# Только то, что объявлено здесь, доступно снаружи через:
# module.container_web.container_id
# ============================================================

output "container_id" {
  description = "ID созданного контейнера"
  value       = docker_container.this.id
}

output "container_name" {
  description = "Полное имя контейнера (с суффиксом окружения)"
  value       = docker_container.this.name
}

output "image_id" {
  description = "ID образа"
  value       = docker_image.this.image_id
}

output "external_port" {
  description = "Порт на хосте"
  value       = var.external_port
}
