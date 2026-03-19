# ============================================================
# Урок 05: State — как Terraform помнит что создал
# ============================================================
#
# В Ansible нет state. Каждый run — Ansible идёт на хосты
# и проверяет текущее состояние заново. Это медленно, но просто.
#
# Terraform хранит state в файле terraform.tfstate.
# State — это "фотография" инфраструктуры: что создано, какие ID,
# какие атрибуты. При следующем apply Terraform сравнивает:
#   код (желаемое) vs state (что было) vs реальность (что есть)
#
# Для экспериментов используем local+random — не нужен Docker.

resource "random_string" "app_id" {
  length  = 8
  upper   = false
  special = false
}

resource "local_file" "app_info" {
  filename = "${path.module}/output/app_info.txt"
  content  = <<-EOT
    App ID:   ${random_string.app_id.result}
    Created:  managed by Terraform
    Version:  ${var.app_version}
  EOT
}

resource "local_file" "inventory" {
  filename = "${path.module}/output/inventory.ini"
  content  = <<-EOT
    [app_servers]
    app-${random_string.app_id.result} ansible_host=192.168.1.10

    [all:vars]
    app_version=${var.app_version}
  EOT
}
