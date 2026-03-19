# Урок 03: Переменные и Outputs

## Концепция

В Ansible переменные разбросаны по group_vars, host_vars, defaults, extra-vars.
В Terraform всё явно: объявляешь в `variable {}`, используешь как `var.name`.

## Файлы этого урока

| Файл | Что делает | Аналогия в Ansible |
|------|------------|-------------------|
| `variables.tf` | Объявление переменных (тип, default, описание) | `defaults/main.yml` роли |
| `main.tf` | Ресурсы — используют `var.xxx` и `local.xxx` | playbook с `{{ переменные }}` |
| `outputs.tf` | Что показать после apply | `debug` + `register` |
| `terraform.tfvars` | Значения переменных | `group_vars/all.yml` |

## Команды

```bash
cd 03-variables

terraform init
terraform plan        # спросит environment (нет default)
terraform apply       # покажет outputs в конце

# Посмотреть outputs после apply (без повторного apply)
terraform output
terraform output access_url
```

## Эксперименты

### Эксперимент 1: Способы передачи переменных

```bash
# Через командную строку (высший приоритет, как -e в Ansible)
terraform plan -var="environment=prod" -var="external_port=9090"

# Через переменную окружения (префикс TF_VAR_)
TF_VAR_environment=staging terraform plan

# Через отдельный файл
terraform plan -var-file="prod.tfvars"
```

### Эксперимент 2: Создай prod.tfvars

Создай файл `prod.tfvars`:
```hcl
environment    = "prod"
container_name = "production-nginx"
external_port  = 80
env_vars = [
  "NGINX_HOST=myapp.com",
  "APP_VERSION=2.0",
]
```

Запусти:
```bash
terraform plan -var-file="prod.tfvars"
```

### Эксперимент 3: Validation (проверка значений)

Добавь в `variables.tf` блок validation к переменной `environment`:
```hcl
variable "environment" {
  description = "Окружение (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment должен быть dev, staging или prod"
  }
}
```

Попробуй передать невалидное значение:
```bash
terraform plan -var="environment=test"
# Error: environment должен быть dev, staging или prod
```

## Приоритет переменных (от низшего к высшему)

```
default в variable {}     ← самый низкий
terraform.tfvars
*.auto.tfvars
TF_VAR_xxx (env)
-var-file="..."
-var="..."                ← самый высокий
```

Как в Ansible: `-e key=value` перебивает всё, `-e @vars.yml` перебивается только `-e key=value`.
