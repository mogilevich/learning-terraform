# ============================================================
# Урок 08: Циклы — count и for_each
# ============================================================
#
# Аналогия с Ansible:
#   count    ≈ loop: [1, 2, 3]  (создать N одинаковых)
#   for_each ≈ loop: "{{ services }}"  (создать по одному на каждый элемент)
#
# Главное правило выбора:
#   count    — когда нужно N одинаковых ресурсов
#   for_each — когда ресурсы отличаются (разные имена, порты, конфиг)
#
# Почему for_each лучше count в большинстве случаев — см. README.

# ------------------------------------------------------------
# Общая сеть
# ------------------------------------------------------------
resource "docker_network" "app" {
  name = "learn-loops-${var.environment}"
}

# ============================================================
# ЧАСТЬ 1: count
# ============================================================

resource "docker_image" "nginx" {
  name         = "nginx:alpine"
  keep_locally = true
}

# count — создаёт N копий ресурса.
# count.index — индекс итерации (0, 1, 2, ...)
#
# Аналог Ansible:
#   - name: Run web containers
#     docker_container:
#       name: "web-{{ item }}"
#     loop: [0, 1, 2]
resource "docker_container" "web" {
  count = var.web_count # создаст web_count контейнеров

  name  = "web-${var.environment}-${count.index}"
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = 8090 + count.index # 8090, 8091, 8092
  }

  networks_advanced {
    name = docker_network.app.name
  }
}

# ============================================================
# ЧАСТЬ 2: for_each
# ============================================================

# for_each с map — каждый элемент map становится отдельным ресурсом.
# each.key   — ключ   (например "web", "api", "admin")
# each.value — значение (объект с image и port)
#
# Аналог Ansible:
#   - name: Run services
#     docker_container:
#       name: "{{ item.key }}"
#       image: "{{ item.value.image }}"
#     loop: "{{ services | dict2items }}"
resource "docker_container" "service" {
  for_each = var.services

  name  = "${each.key}-${var.environment}"
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = each.value.port
  }

  networks_advanced {
    name = docker_network.app.name
  }

  env = [
    "SERVICE_NAME=${each.key}",
    "APP_ENV=${var.environment}",
  ]
}

# ============================================================
# ЧАСТЬ 3: for_each с set(string)
# ============================================================

# Если нужен for_each по простому списку — преобразуй в set:
# toset(["dev", "staging"]) → for_each итерирует по значениям
# each.key == each.value для set
resource "random_string" "token" {
  for_each = toset(["web", "api", "admin"])

  length  = 16
  special = false

  keepers = {
    service = each.key
  }
}
