# ============================================================
# Урок 02: Ресурсы — жизненный цикл и поведение при изменениях
# ============================================================
#
# В Ansible ты пишешь таски — каждый выполняется по порядку.
# В Terraform ты описываешь ресурсы — желаемое состояние.
# Terraform сравнивает "что есть" (state) с "что хочешь" (код)
# и вычисляет минимальный набор действий.
#
# Три возможных действия:
#   create  — ресурса нет → создать
#   update  — ресурс есть, параметр можно изменить на месте → обновить
#   replace — ресурс есть, но параметр нельзя изменить без пересоздания → удалить + создать заново
#
# Docker-объекты иммутабельны, поэтому Docker-провайдер почти всегда делает replace.
# Update in-place чаще встречается у облачных провайдеров (AWS, GCP) — например,
# изменение тегов у EC2 инстанса не требует его пересоздания.
# Что именно будет — всегда видно в `terraform plan`.

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
# Ресурс 1: Docker-сеть
# Новая концепция — ресурсы могут быть не только контейнерами.
# Аналогия: таск docker_network в Ansible.
# ------------------------------------------------------------
resource "docker_network" "app_network" {
  name = "learn-terraform-net"
  # labels {
  #   label = "env1"
  #   value = "dev"
  # }
}

# ------------------------------------------------------------
# Ресурс 2: образ
# ------------------------------------------------------------
resource "docker_image" "nginx" {
  name         = "nginx:alpine"
  keep_locally = true
}

# ------------------------------------------------------------
# Ресурс 3: контейнер
#
# Обрати внимание на ссылки:
#   docker_image.nginx.image_id   → зависимость от образа
#   docker_network.app_network.id → зависимость от сети
#
# Terraform строит граф зависимостей автоматически:
#   сеть ──┐
#          ├──→ контейнер
#   образ ─┘
#
# Сеть и образ создадутся ПАРАЛЛЕЛЬНО (они не зависят друг от друга),
# контейнер — после обоих. В Ansible для этого нужен async или отдельный play.
# ------------------------------------------------------------
resource "docker_container" "web" {
  name  = "learn-terraform-web-v2"
  image = docker_image.nginx.image_id

  # Подключаем к нашей сети
  networks_advanced {
    name = docker_network.app_network.name
  }

  ports {
    internal = 80
    external = 8080
  }

  # ── Метки (labels) ──
  # Их можно менять — Terraform обновит контейнер БЕЗ пересоздания (update in-place).
  labels {
    label = "environment"
    value = "dev"
  }

  labels {
    label = "managed_by"
    value = "terraform"
  }

  # ── Переменные окружения ──
  env = [
    "NGINX_HOST=localhost",
    "APP_VERSION=2.0",
  ]
}

# ------------------------------------------------------------
# Ресурс 4: ещё один контейнер — Redis
# Демонстрация: в одном файле может быть сколько угодно ресурсов.
# Terraform создаст его параллельно с nginx (они не зависят друг от друга).
# ------------------------------------------------------------
resource "docker_image" "redis" {
  name         = "redis:alpine"
  keep_locally = true
}

resource "docker_container" "cache" {
  name  = "learn-terraform-cache"
  image = docker_image.redis.image_id

  networks_advanced {
    name = docker_network.app_network.name
  }

  # Redis слушает на 6379, пробросим как есть
  ports {
    internal = 6379
    external = 6379
  }

  labels {
    label = "environment"
    value = "dev"
  }
}
