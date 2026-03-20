variable "environment" {
  type    = string
  default = "dev"
}

# Для count — просто число
variable "web_count" {
  description = "Сколько web-контейнеров поднять"
  type        = number
  default     = 3
}

# Для for_each — map с конфигом каждого сервиса
variable "services" {
  description = "Сервисы для запуска (for_each)"
  type = map(object({
    image : string
    port : number
  }))
  default = {
    web = {
      image = "nginx:alpine"
      port  = 8080
    }
    api = {
      image = "nginx:alpine"
      port  = 8081
    }
    admin = {
      image = "nginx:alpine"
      port  = 8082
    }
  }
}
