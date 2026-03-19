variable "environment" {
  description = "Окружение"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Допустимые значения: dev, staging, prod"
  }
}

variable "app_name" {
  description = "Имя приложения"
  type        = string
  default     = "myapp"
}

variable "db_password_length" {
  description = "Длина генерируемого пароля"
  type        = number
  default     = 16
}
