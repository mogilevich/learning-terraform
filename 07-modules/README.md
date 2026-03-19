# Урок 07: Модули

## Что изучаем

- Модуль = переиспользуемый блок конфигурации (как роль в Ansible)
- Корневой модуль (root) vs дочерний модуль (child)
- Передача данных: variables (внутрь) и outputs (наружу)
- Как вызвать один модуль несколько раз с разными параметрами

## Структура

```
07-modules/
├── main.tf             ← корневой модуль: вызывает дочерние
├── variables.tf
├── outputs.tf
└── modules/
    └── container/      ← дочерний модуль
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

Модуль — это просто папка с `.tf` файлами. Никакой магии.

## Запуск

```bash
terraform init    # нужен при добавлении модулей
terraform plan    # превью: увидишь 5 ресурсов (сеть + 2×образ + 2×контейнер)
terraform apply   # применить
terraform output  # посмотреть имена контейнеров и URLs
```

## Эксперимент 1: outputs модуля

После apply — посмотри как достать данные из модуля:

```bash
terraform output web_container_name   # → "web-dev"
terraform output api_container_name   # → "api-dev"

# Зайти в terraform console и поиграть с module.*
terraform console
> module.web.container_name
> module.api.image_id
```

## Эксперимент 2: вызов модуля с другим окружением

```bash
terraform plan -var="environment=staging"   # превью: replace контейнеров (имя изменится)
terraform apply -var="environment=staging"
terraform output
# web_container_name = "web-staging"
# api_container_name = "api-staging"
```

Один модуль, два разных окружения — как роль Ansible с разными `host_vars`.

## Эксперимент 3: добавить третий контейнер

Добавь в `main.tf` ещё один вызов модуля:

```hcl
module "cache" {
  source = "./modules/container"

  name          = "cache"
  image         = "redis:alpine"
  internal_port = 6379
  external_port = 6379
  environment   = var.environment
  network_name  = docker_network.app.name
}
```

```bash
terraform init    # обязательно при добавлении нового модуля — Terraform регистрирует модули при init, а не при plan
terraform plan    # увидишь только новые ресурсы для cache, web и api не тронуты
terraform apply
```

> **Правило:** каждый раз когда добавляешь новый `module {}` блок — нужен `terraform init`.
> Без него `terraform plan` упадёт с `Error: Module not installed`.

## Аналогия модуль ↔ роль Ansible

| Terraform | Ansible |
|-----------|---------|
| `module "web" { source = "./modules/container" }` | `- role: container` |
| `variable {}` в модуле | `defaults/main.yml` роли |
| `outputs {}` в модуле | `register:` результат роли |
| `module.web.container_name` | `"{{ hostvars[...] }}"` |
| `source = "./modules/container"` | локальная роль в `roles/` |
| `source = "terraform-aws-modules/vpc/aws"` | роль из Ansible Galaxy |

## Что важно запомнить

- После добавления нового модуля всегда нужен `terraform init`
- Модуль видит только то, что ему передали через `variable {}`
- Наружу отдаёт только то, что объявлено в его `outputs.tf`
- Внутри модуля нельзя обратиться к ресурсам родителя напрямую
