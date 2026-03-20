# Урок 08: Циклы — count и for_each

## Что изучаем

- `count` — создать N одинаковых ресурсов
- `for_each` — создать по ресурсу на каждый элемент map/set
- `count.index`, `each.key`, `each.value`
- for-выражения в outputs
- Когда использовать count, а когда for_each

## Запуск

```bash
terraform init
terraform plan    # превью: увидишь 3+3 контейнера + 3 токена
terraform apply   # применить
terraform output  # посмотреть результаты
```

## count vs for_each — главное отличие

**count** адресует ресурсы по индексу:
```
docker_container.web[0]
docker_container.web[1]
docker_container.web[2]
```

**for_each** адресует по ключу:
```
docker_container.service["web"]
docker_container.service["api"]
docker_container.service["admin"]
```

### Почему это важно

Представь: у тебя 3 контейнера через `count` — `[0]`, `[1]`, `[2]`.
Нужно удалить средний (`[1]`).

```bash
terraform plan
```

Terraform увидит:
```
~ docker_container.web[1]   # был "web-1" → станет "web-2" (сдвиг!)
- docker_container.web[2]   # удалить
```

Вместо удаления одного — **пересоздаст два**. Потому что индексы сдвинулись.

С `for_each` такой проблемы нет — ключи `"web"`, `"api"`, `"admin"` не сдвигаются при удалении одного.

**Правило:** используй `count` только для N абсолютно одинаковых ресурсов (реплики, инстансы одного типа). В остальных случаях — `for_each`.

## Эксперимент 1: count.index

Посмотри что создалось:
```bash
terraform output web_names   # → ["web-dev-0", "web-dev-1", "web-dev-2"]
terraform output web_ports   # → [8090, 8091, 8092]
docker ps --filter name=web-dev
```

Измени `web_count` в `terraform.tfvars` на `2`:
```bash
terraform plan    # увидишь: 1 destroy (web-dev-2 удалится)
terraform apply
```

## Эксперимент 2: добавить сервис в for_each

Создай файл `override.tfvars` с новым сервисом:

```hcl
services = {
  web     = { image = "nginx:alpine", port = 8080 }
  api     = { image = "nginx:alpine", port = 8081 }
  admin   = { image = "nginx:alpine", port = 8082 }
  metrics = { image = "nginx:alpine", port = 8083 }  # новый
}
```

```bash
terraform plan -var-file=override.tfvars    # только 1 новый ресурс — остальные не тронуты
terraform apply -var-file=override.tfvars
terraform output service_ports
```

## Эксперимент 3: удалить один сервис из for_each

В `override.tfvars` закомментируй `admin` (комментарии внутри map работают):

```hcl
services = {
  web     = { image = "nginx:alpine", port = 8080 }
  api     = { image = "nginx:alpine", port = 8081 }
  # admin = { image = "nginx:alpine", port = 8082 }  ← закомментировали
  metrics = { image = "nginx:alpine", port = 8083 }
}
```

```bash
terraform plan -var-file=override.tfvars    # только 1 destroy — web, api, metrics не тронуты
terraform apply -var-file=override.tfvars
```

Сравни с тем что было бы с `count` — там бы сдвинулись индексы.

## for-выражения

Terraform поддерживает for-выражения в outputs и locals:

```hcl
# Список → список (фильтрация)
[for c in docker_container.web : c.name if c.ports[0].external > 8090]

# Map → map (трансформация)
{ for k, v in docker_container.service : k => v.ports[0].external }

# Map → список
[for k, v in var.services : "${k}:${v.port}"]
```

Аналог в Ansible:
```yaml
# Jinja2
{{ services | dict2items | map(attribute='key') | list }}
{{ services.values() | map(attribute='port') | list }}
```
