# ============================================================
# Входные переменные модуля — его "API"
# Аналог: параметры роли в Ansible (defaults/main.yml + vars/main.yml)
# ============================================================

variable "name" {
  description = "Имя контейнера"
  type        = string
}

variable "image" {
  description = "Docker образ (например nginx:alpine)"
  type        = string
}

variable "internal_port" {
  description = "Порт внутри контейнера"
  type        = number
  default     = 80
}

variable "external_port" {
  description = "Порт на хосте"
  type        = number
}

variable "environment" {
  description = "Окружение: dev, staging, prod"
  type        = string
  default     = "dev"
}

variable "env_vars" {
  description = "Переменные окружения для контейнера"
  type        = list(string)
  default     = []
}

variable "network_name" {
  description = "Docker-сеть для подключения контейнера"
  type        = string
  default     = null # null = не подключать к сети
}
