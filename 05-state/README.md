# Урок 05: State — как Terraform помнит что создал

## Концепция

В Ansible нет state. При каждом запуске Ansible идёт на хосты и сам проверяет текущее состояние.
В Terraform state — это база данных: что создано, какие ID, какие атрибуты.

```
Ansible:  код → хост (проверяет реальность каждый раз напрямую)
Terraform: код + state + refresh реальности → план изменений
```

При каждом `plan`/`apply` Terraform делает три вещи:
1. Читает **код** — желаемое состояние
2. Делает **refresh** — идёт к провайдеру и обновляет state актуальными данными из реальности
3. Сравнивает обновлённый **state** с **кодом** — строит план

State — это **кэш** последнего известного состояния, не истина в последней инстанции.
Если удалить файл/контейнер вручную — refresh это обнаружит, и Terraform создаст его заново.

## Запуск

```bash
terraform init
terraform plan    # превью: 3 ресурса к созданию
terraform apply   # применить: создаст файлы в output/
```

После apply появится `terraform.tfstate` — посмотри его:

```bash
cat terraform.tfstate | jq .   # вся база данных ресурсов
```

## Что внутри state

```bash
# Список всех ресурсов в state
terraform state list

# Детали конкретного ресурса (все атрибуты)
terraform state show random_string.app_id
terraform state show local_file.app_info
```

Ты увидишь все атрибуты ресурса — в том числе те, которые Terraform получил от провайдера после создания (ID, хеши и т.д.). Именно это Terraform использует при следующем `plan`.

## Эксперимент 1: что происходит без изменений

```bash
terraform plan    # → No changes. Your infrastructure matches the configuration.
```

Terraform сравнил код со state — всё совпадает. Ничего делать не нужно.

В Ansible каждый раз идут реальные проверки на хост, даже если ничего не изменилось.
В Terraform — быстрое сравнение с state (refresh + diff).

## Эксперимент 2: изменение — state видит разницу

Измени `app_version` в `terraform.tfvars` или передай через `-var`:

```bash
terraform plan -var="app_version=2.0"    # превью: увидишь изменения в файлах
terraform apply -var="app_version=2.0"   # применить
cat output/app_info.txt                   # Version: 2.0
cat output/inventory.ini                  # app_version=2.0
```

## Эксперимент 3: удаление ресурса из state вручную

Иногда нужно "забыть" ресурс из state, не удаляя его реально.
Например: ресурс создан вручную и ты хочешь Terraform о нём забыл.

```bash
# Удалить из state (файл на диске НЕ удаляется)
terraform state rm local_file.inventory

# Теперь Terraform "не знает" об этом файле
terraform plan    # покажет: + create local_file.inventory (хочет создать заново)
terraform apply   # пересоздаст файл
```

Это не деструктивная операция — реальный файл остался на диске, просто Terraform его "забыл".

## Эксперимент 4: перемещение ресурса в state

Переименовал ресурс в коде? Без `mv` Terraform удалит старый и создаст новый.

Переименуй в `main.tf`:
```hcl
# было:
resource "local_file" "inventory" { ... }

# стало:
resource "local_file" "hosts" { ... }
```

```bash
terraform plan    # покажет: -destroy inventory, +create hosts
```

Не применяй. Вместо этого — переименуй в state:

```bash
terraform state mv local_file.inventory local_file.hosts
terraform plan    # → No changes. Terraform "понял" что это тот же ресурс
```

Верни имя `inventory` в коде после эксперимента.

## Эксперимент 5: что будет если удалить state

```bash
# Сделай резервную копию
cp terraform.tfstate terraform.tfstate.backup

# Удали state
rm terraform.tfstate

# Что скажет Terraform?
terraform plan    # покажет: +create все ресурсы заново!
```

Terraform не знает что файлы уже есть — он хочет создать всё заново.
Восстанови state:

```bash
cp terraform.tfstate.backup terraform.tfstate
terraform plan    # → No changes.
```

**Вывод:** state — это единственная "память" Terraform. Потерял state — Terraform потерял инфраструктуру. Именно поэтому нужен remote backend (урок 11).

## Команды для работы со state

| Команда | Что делает |
|---------|-----------|
| `terraform state list` | Список всех ресурсов |
| `terraform state show <ресурс>` | Все атрибуты ресурса |
| `terraform state rm <ресурс>` | Удалить из state (не трогая реальный объект) |
| `terraform state mv <откуда> <куда>` | Переименовать в state |
| `terraform show` | Весь state в читаемом виде |
| `terraform show -json` | Весь state в JSON |
| `terraform refresh` | Обновить state из реальности (deprecated, теперь часть plan/apply) |

## State и секреты

State хранит **все** атрибуты в открытом виде — включая пароли и токены.
`terraform.tfstate` нельзя коммитить в git. Решение — remote backend (урок 11):
S3, GCS, Terraform Cloud и другие. Там state шифруется и доступ контролируется.
