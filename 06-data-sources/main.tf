# ============================================================
# Урок 06: Data Sources — читаем существующие данные
# ============================================================
#
# resource {} — СОЗДАЁТ и управляет ресурсом
# data {}     — ЧИТАЕТ существующий ресурс или данные, ничего не создаёт
#
# Аналогии в Ansible:
#   - gather_facts     → читает факты хоста
#   - lookup('file')   → читает файл
#   - lookup('aws_*')  → читает данные из AWS
#   - set_fact         → как locals, но data ещё и к провайдеру идёт
#
# data{} нужен когда ресурс уже существует (создан руками или другим модулем)
# и тебе нужно получить его атрибуты — ID, IP, ARN и т.д.

# ------------------------------------------------------------
# data "local_file" — читает файл с диска (не создаёт)
# Аналог: lookup('file', 'path') в Ansible
# ------------------------------------------------------------
data "local_file" "servers_json" {
  filename = "${path.module}/files/servers.json"
}

data "local_file" "db_config" {
  filename = "${path.module}/files/db_config.txt"
}

# ------------------------------------------------------------
# Разбираем JSON из файла через jsondecode()
# Аналог: from_json filter в Ansible
# ------------------------------------------------------------
locals {
  servers_data = jsondecode(data.local_file.servers_json.content)
  environment  = local.servers_data.environment
  domain       = local.servers_data.domain
}

# ------------------------------------------------------------
# Используем данные из data sources в resource
# ------------------------------------------------------------
resource "local_file" "inventory" {
  filename = "${path.module}/output/inventory.ini"
  content  = <<-EOT
    # Сгенерировано Terraform из files/servers.json
    # Окружение: ${local.environment}

    [web]
    %{for s in local.servers_data.servers~}
    %{if s.role == "web"~}
    ${s.name} ansible_host=${s.ip}
    %{endif~}
    %{endfor~}

    [db]
    %{for s in local.servers_data.servers~}
    %{if s.role == "db"~}
    ${s.name} ansible_host=${s.ip}
    %{endif~}
    %{endfor~}

    [all:vars]
    domain=${local.domain}
  EOT
}

resource "local_file" "app_config" {
  filename = "${path.module}/output/app.env"
  content  = <<-EOT
    # Конфиг приложения
    # БД из files/db_config.txt
    ${data.local_file.db_config.content}
  EOT
}
