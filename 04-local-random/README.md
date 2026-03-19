# Урок 04: Провайдеры local и random

## Что изучаем

- `random_string` / `random_password` — генерация и идемпотентность
- `local_file` / `local_sensitive_file` — генерация файлов из шаблонов
- `templatefile()` — шаблоны конфигов (аналог Jinja2 в Ansible)
- `sensitive` outputs — скрытые значения

## Запуск

```bash
terraform init
terraform plan    # превью: увидишь 3 ресурса к созданию
terraform apply   # применить: создаст файлы в output/
```

После apply в папке `output/` появятся два файла:
- `app.conf` — конфиг приложения из шаблона
- `db.env` — credentials (права 0600)

## Эксперимент 1: как Terraform видит изменение файла

Измени что-нибудь в [templates/app.conf.tpl](templates/app.conf.tpl),
например добавь строку `log_level = info`.

```bash
terraform plan    # превью: увидишь -/+ replace
terraform apply   # применить: файл пересоздаётся с новой строкой
cat output/app.conf  # проверяешь результат
```

Увидишь `-/+` (replace) — Terraform пересоздаёт файл, потому что его ID
это SHA1 от содержимого. Изменился контент → изменился ID → replace.

Так работают все `local_file` — Terraform не патчит файлы построчно,
он всегда пишет новый. Настоящий `~` update in-place бывает только у
облачных ресурсов с мутабельными атрибутами (теги у EC2, DNS-записи).

## Эксперимент 2: идемпотентность random

Запусти apply несколько раз подряд:

```bash
terraform apply   # первый раз — создаёт ресурсы
terraform apply   # второй — "No changes"
terraform apply   # третий — "No changes"
```

Суффикс в `output/app.conf` каждый раз **одинаковый**.
Terraform берёт значение из state, не генерирует заново.

## Эксперимент 3: sensitive output

```bash
terraform output                    # → все outputs, db_password = (sensitive value)
terraform output db_password        # → показывает значение (Terraform 1.9+: явный запрос = показать)
terraform output -raw db_password   # → значение без кавычек (удобно для скриптов)
terraform output -json              # → все outputs в JSON, sensitive значения видны
```

Посмотреть sensitive значение в state (хранится открытым текстом!):
```bash
# terraform state show скрывает sensitive — пишет (sensitive value)
terraform state show random_password.db

# Напрямую из JSON state — здесь уже всё открыто:
terraform show -json | jq '.values.root_module.resources[] | select(.address=="random_password.db") | .values.result'

# Или просто открой файл — пароль там в открытом виде:
cat terraform.tfstate | jq '.resources[] | select(.name=="db") | .instances[].attributes.result'
```

Вывод: **state содержит секреты в открытом виде** → не коммить в git, используй remote backend (урок 11).

## Эксперимент 4: keepers — принудительная замена

`random_*` пересоздаётся только если изменились его параметры (`length`, `special` и т.д.).
Но иногда нужно пересоздать пароль/строку при каком-то внешнем событии — для этого `keepers`.

`keepers` — map произвольных ключей/значений. Terraform просто сравнивает старые и новые значения.
Изменилось хоть одно — ресурс пересоздаётся. Сами значения смысла не имеют, важен факт изменения.

### Сценарий 1: ротация пароля при деплое новой версии

```hcl
resource "random_password" "db" {
  length  = 16
  special = true

  keepers = {
    app_version = var.app_version  # "1.0" → "2.0" = новый пароль при следующем apply
  }
}
```

Без `keepers` пароль живёт вечно — `length=16` и `special=true` не изменились, Terraform ничего не делает.

### Сценарий 2: новый суффикс при смене окружения

```hcl
resource "random_string" "suffix" {
  length = 6

  keepers = {
    environment = var.environment  # dev → prod = новый суффикс = новые имена ресурсов
  }
}
```

**Попробуй:**

Добавь `keepers` в `random_string.suffix` в `main.tf`, укажи любое значение.

```bash
terraform plan    # No changes (keepers добавился, но значение то же)
terraform apply
```

Измени значение в `keepers`:

```bash
terraform plan    # увидишь: -/+ random_string.suffix must be replaced
terraform apply   # новый суффикс, файл конфига пересоздастся с новым именем
cat output/app.conf
```

**Аналогия с Ansible:** прямого аналога нет, потому что Ansible не хранит state.
Ближайшее — `notify` handler: "запусти это только когда произошло вот то".
Но там про запуск таска, здесь — про пересоздание ресурса.

## Что такое templatefile()

```hcl
templatefile("путь/к/шаблону.tpl", { переменная = значение })
```

Аналог Ansible `template` модуля с Jinja2, но синтаксис другой:
- Ansible: `{{ переменная }}`
- Terraform: `${переменная}`

В шаблоне доступны **только** переменные из второго аргумента — `var.*` и `local.*` напрямую недоступны, нужно передавать явно:

```hcl
# main.tf — передаём явно то, что нужно шаблону
templatefile("templates/app.conf.tpl", {
  app_name    = var.app_name       # ✓ передали — доступно в шаблоне
  environment = var.environment    # ✓ передали — доступно в шаблоне
  suffix      = random_string.suffix.result
})
```

```ini
# app.conf.tpl
name = ${app_name}              # ✓ работает — передали выше
env  = ${environment}           # ✓ работает — передали выше
port = ${var.external_port}     # ✗ ОШИБКА — var.* в шаблоне недоступен
```

В Ansible наоборот — в Jinja2 все переменные доступны автоматически без явной передачи.
Terraform более явный: в шаблон попадает только то, что ты сам туда передал.
