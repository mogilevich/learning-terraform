# ============================================================
# Урок 03: Переменные (variables)
# ============================================================
#
# В Ansible переменные задаются в group_vars, host_vars, --extra-vars, defaults/.
# В Terraform — блоки variable {} в отдельном файле.
#
# Файл можно назвать как угодно (.tf), но по конвенции — variables.tf.
# Terraform читает ВСЕ .tf файлы в папке и склеивает их в один конфиг.

# ------------------------------------------------------------
# Простая переменная — строка
# Аналогия: переменная в defaults/main.yml роли Ansible
# ------------------------------------------------------------
variable "container_name" {
  description = "Имя Docker-контейнера"
  type        = string
  default     = "learn-terraform-web"
}

# ------------------------------------------------------------
# Число
# ------------------------------------------------------------
variable "external_port" {
  description = "Порт на хосте"
  type        = number
  default     = 8080
}

# ------------------------------------------------------------
# Переменная БЕЗ default — Terraform спросит при apply
# Как --extra-vars в Ansible — обязательно передать
# ------------------------------------------------------------
variable "environment" {
  description = "Окружение (dev, staging, prod)"
  type        = string
  # нет default — Terraform потребует значение
}

# ------------------------------------------------------------
# Bool
# ------------------------------------------------------------
variable "remove_image_on_destroy" {
  description = "Удалять образ при terraform destroy?"
  type        = bool
  default     = false
}

# ------------------------------------------------------------
# List — список строк
# Аналогия: list в Ansible (["a", "b", "c"])
# ------------------------------------------------------------
variable "env_vars" {
  description = "Переменные окружения для контейнера"
  type        = list(string)
  default = [
    "NGINX_HOST=localhost",
    "APP_VERSION=1.0",
  ]
}

# ------------------------------------------------------------
# Map — словарь
# Аналогия: dict в Ansible ({key: value})
# ------------------------------------------------------------
variable "labels" {
  description = "Метки для контейнера"
  type        = map(string)
  default = {
    managed_by = "terraform"
    project    = "learning"
  }
}
