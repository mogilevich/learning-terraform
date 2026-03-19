# Урок 06: Data Sources — читаем существующие данные

## Концепция

```hcl
resource "тип" "имя" { }  # СОЗДАЁТ и управляет ресурсом
data   "тип" "имя" { }   # ЧИТАЕТ существующий — ничего не создаёт
```

Data source нужен когда ресурс уже существует и тебе нужно получить его атрибуты.

Аналогии в Ansible:

| Terraform | Ansible |
|-----------|---------|
| `data "local_file"` | `lookup('file', 'path')` |
| `data "docker_image"` | `docker_image_info` модуль |
| `data "aws_ami"` | `ec2_ami_info` модуль |
| `jsondecode(data.x.content)` | `from_json` filter |

## Запуск

> Для `data "docker_image"` нужен образ `nginx:alpine` на машине.
> Если нет — `docker pull nginx:alpine`.

```bash
terraform init
terraform plan    # превью: только 2 local_file к созданию (data не создаёт ничего)
terraform apply   # применить: создаст файлы в output/
cat output/inventory.ini
cat output/app.env
```

## Как ссылаться на data source

```hcl
# resource: docker_image.nginx.image_id
# data:     data.docker_image.nginx.id
#           ^^^^
#           префикс data. — отличает от ресурса
```

## Эксперимент 1: data читается при plan, не при apply

```bash
terraform plan    # data sources читаются ЗДЕСЬ — до создания ресурсов
terraform apply
```

Если файл `files/servers.json` не существует — `plan` упадёт сразу.
Data source это зависимость: сначала читаем данные, потом создаём ресурсы на их основе.

## Эксперимент 2: добавь сервер в servers.json

Добавь новый сервер в [files/servers.json](files/servers.json):
```json
{ "name": "web-03", "ip": "192.168.1.12", "role": "web" }
```

```bash
terraform plan    # превью: inventory.ini изменится — replace (local_file всегда replace)
terraform apply   # применить
cat output/inventory.ini   # web-03 появился в секции [web]
```

## Эксперимент 3: jsondecode и for выражения

Посмотри в `terraform console` как работает разбор JSON:

```bash
terraform console
```

```hcl
# Разобрать JSON файл
jsondecode(file("files/servers.json"))

# Получить список серверов
jsondecode(file("files/servers.json")).servers

# Фильтр — только web серверы
[for s in jsondecode(file("files/servers.json")).servers : s.name if s.role == "web"]

# Выход из консоли
Ctrl+C
```

## Когда использовать data вместо resource

| Ситуация | Решение |
|----------|---------|
| Ресурс создан вручную, нужны его атрибуты | `data` |
| Ресурс создан другим Terraform-проектом | `data` (+ remote state, урок 11) |
| Нужно прочитать файл/API без создания чего-либо | `data` |
| Ресурс должен создаваться и управляться Terraform | `resource` |
