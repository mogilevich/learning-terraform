# ============================================================
# Урок 04: Провайдеры local и random
# ============================================================
#
# Зачем этот урок:
#   1. local_file показывает настоящий update in-place (без пересоздания)
#   2. random показывает sensitive outputs и идемпотентность
#   3. Оба провайдера встроены — не нужен Docker/AWS
#
# Идемпотентность — ключевое слово Terraform (и Ansible):
#   запусти apply 100 раз — результат один и тот же.

# ------------------------------------------------------------
# random_string — генерирует строку один раз и запоминает в state.
# При повторном apply — НЕ генерирует заново. Это идемпотентность.
#
# Аналогия: lookup('password', ...) в Ansible, но Ansible
# каждый раз генерирует новое — Terraform запоминает в state.
# ------------------------------------------------------------
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

# ------------------------------------------------------------
# random_password — как random_string, но:
#   1. Значение помечается как sensitive (не выводится в логах)
#   2. Специальные символы включены по умолчанию
# ------------------------------------------------------------
resource "random_password" "db" {
  length           = var.db_password_length
  special          = true
  override_special = "!#$%&*()-_=+[]{}:?"
}

# ------------------------------------------------------------
# local_file — создаёт файл на диске.
# ЕДИНСТВЕННЫЙ ресурс в этих уроках, который делает update in-place:
# измени content → terraform apply обновит файл без пересоздания.
# ------------------------------------------------------------
resource "local_file" "app_config" {
  filename = "${path.module}/output/app.conf"
  content = templatefile("${path.module}/templates/app.conf.tpl", {
    app_name    = var.app_name
    environment = var.environment
    suffix      = random_string.suffix.result
    db_host     = "db-${var.environment}-${random_string.suffix.result}"
  })

  file_permission = "0644"
}

# ------------------------------------------------------------
# local_sensitive_file — как local_file, но содержимое sensitive.
# Terraform не покажет diff в `plan` — только "(sensitive value)".
# ------------------------------------------------------------
resource "local_sensitive_file" "db_credentials" {
  filename = "${path.module}/output/db.env"
  content  = <<-EOT
    DB_HOST=db-${var.environment}-${random_string.suffix.result}
    DB_USER=${var.app_name}_user
    DB_PASSWORD=${random_password.db.result}
  EOT

  file_permission = "0600"
}
