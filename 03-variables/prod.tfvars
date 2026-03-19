environment    = "prod"
container_name = "production-nginx"
external_port  = 80
env_vars = [
  "NGINX_HOST=myapp.com",
  "APP_VERSION=2.0",
]