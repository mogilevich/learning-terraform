# ============================================================
# Модуль: container
# Создаёт Docker-образ + контейнер с метками окружения
#
# Модуль — это просто папка с .tf файлами.
# Он не знает кто его вызывает и из какого окружения.
# Всё что ему нужно — получить через variable {}.
# ============================================================

resource "docker_image" "this" {
  name         = var.image
  keep_locally = true
}

resource "docker_container" "this" {
  name  = "${var.name}-${var.environment}"
  image = docker_image.this.image_id

  ports {
    internal = var.internal_port
    external = var.external_port
  }

  env = var.env_vars

  # Подключаем к сети только если передали network_name
  dynamic "networks_advanced" {
    for_each = var.network_name != null ? [var.network_name] : []
    content {
      name = networks_advanced.value
    }
  }
}
