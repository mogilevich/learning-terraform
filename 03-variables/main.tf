# ============================================================
# Урок 03: Использование переменных и locals
# ============================================================

terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

# ------------------------------------------------------------
# Locals — вычисляемые значения (как set_fact в Ansible).
# Используй когда нужно собрать значение из нескольких переменных
# или не повторять одно и то же выражение.
# ------------------------------------------------------------
locals {
  # Собираем полное имя из переменных
  full_container_name = "${var.container_name}-${var.environment}"

  # Общие метки — добавляем environment к пользовательским
  all_labels = merge(var.labels, {
    environment = var.environment
  })
}

resource "docker_image" "nginx" {
  name         = "nginx:alpine"
  keep_locally = !var.remove_image_on_destroy
}

resource "docker_container" "web" {
  # Используем local вместо повторения выражения
  name  = local.full_container_name
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = var.external_port # ← переменная вместо хардкода
  }

  # env принимает list(string) — передаём переменную напрямую
  env = var.env_vars

  # Динамический блок — создаёт labels из map.
  # Подробнее dynamic разберём в уроке 09, сейчас просто смотри результат.
  dynamic "labels" {
    for_each = local.all_labels
    content {
      label = labels.key
      value = labels.value
    }
  }
}
