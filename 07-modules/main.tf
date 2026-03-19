# ============================================================
# Урок 07: Модули — переиспользование конфигураций
# ============================================================
#
# Модуль в Terraform = роль в Ansible:
#   - принимает параметры (variables)
#   - скрывает детали реализации
#   - возвращает значения (outputs)
#   - можно вызывать несколько раз с разными параметрами
#
# Структура:
#   07-modules/           ← корневой модуль (root module)
#     main.tf             ← вызываем дочерние модули отсюда
#     modules/
#       container/        ← дочерний модуль (child module)
#         main.tf
#         variables.tf
#         outputs.tf

# ------------------------------------------------------------
# Общая сеть для всех контейнеров
# ------------------------------------------------------------
resource "docker_network" "app" {
  name = "learn-modules-net"
}

# ------------------------------------------------------------
# Вызов модуля — как вызов роли в Ansible
#
# Ansible:
#   roles:
#     - role: my_container
#       vars:
#         name: web
#         image: nginx:alpine
#
# Terraform:
#   module "container_web" {
#     source = "./modules/container"
#     name   = "web"
#     image  = "nginx:alpine"
#   }
# ------------------------------------------------------------
module "web" {
  source = "./modules/container"

  name          = "web"
  image         = "nginx:alpine"
  external_port = 8080
  environment   = var.environment
  network_name  = docker_network.app.name

  env_vars = [
    "NGINX_HOST=localhost",
    "APP_ENV=${var.environment}",
  ]
}

module "api" {
  source = "./modules/container"

  name          = "api"
  image         = "nginx:alpine" # в реальности был бы свой образ
  internal_port = 80
  external_port = 8081
  environment   = var.environment
  network_name  = docker_network.app.name

  env_vars = [
    "APP_ENV=${var.environment}",
    "API_VERSION=v1",
  ]
}

module "cache" {
  source = "./modules/container"

  name          = "cache"
  image         = "redis:alpine"
  internal_port = 6379
  external_port = 6379
  environment   = var.environment
  network_name  = docker_network.app.name
}