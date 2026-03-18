# Урок 02: Ресурсы — жизненный цикл и поведение при изменениях

## Что нового

В уроке 01 мы создали один контейнер. Теперь:
- несколько ресурсов разных типов (сеть, образы, контейнеры)
- Terraform сам определяет порядок и параллелизм
- изучаем действия Terraform: **create**, **replace**, **destroy**
- узнаём почему Docker-провайдер почти всегда пересоздаёт (иммутабельность Docker)

## Команды

```bash
cd 02-resources

# 1. Инициализация
terraform init

# 2. Посмотри план — будет 5 ресурсов к созданию
terraform plan

# 3. Применить
terraform apply

# 4. Проверить
docker ps                    # два контейнера
docker network ls            # сеть learn-terraform-net
curl localhost:8080          # nginx
docker exec learn-terraform-cache redis-cli ping  # PONG
```

## Эксперименты

Это главная часть урока. Делай изменения и смотри что покажет `terraform plan`.

### Эксперимент 1: Replace (пересоздание)

Docker-контейнеры иммутабельны — **любое** изменение параметров ведёт к пересозданию. Это не Terraform так решил, а сам Docker так работает (ты это знаешь — `docker run` создаёт новый контейнер, нельзя на лету поменять env или порт).

Измени имя контейнера:
```hcl
resource "docker_container" "web" {
  name  = "learn-terraform-web-v2"   # было "learn-terraform-web"
```
Запусти `terraform plan` — увидишь `-/+ must be replaced`.

### Эксперимент 2: Удаление ресурса

Закомментируй или удали весь блок `docker_container.cache` и `docker_image.redis`.
Запусти `terraform plan` — увидишь `- destroy`. Terraform удалит то, чего больше нет в коде.

### Эксперимент 3: -target — работа с конкретным ресурсом

Флаг `-target` работает с `plan`, `apply` и `destroy` — как `--limit` / `--tags` в Ansible, только точнее (конкретный ресурс, а не группа хостов).

```bash
# Посмотреть план только для одного ресурса
terraform plan -target=docker_container.cache

# Применить изменения только для одного ресурса
terraform apply -target=docker_container.cache

# Удалить только один ресурс, не трогая остальные
terraform destroy -target=docker_container.cache

# Несколько целей сразу
terraform plan -target=docker_container.cache -target=docker_image.redis
```

## Ключевые выводы

| Концепция | Ansible | Terraform |
|-----------|---------|-----------|
| Порядок выполнения | сверху вниз по файлу | автоматический граф зависимостей |
| Параллелизм | нужен `async`/`strategy: free` | по умолчанию параллельно |
| Что делать при изменении | модуль решает сам | явно видно в plan: update/replace |
| Удаление | нужен отдельный таск с `state: absent` | убрал из кода → Terraform удалит |

Последний пункт — **главное отличие**: в Ansible, если ты удалишь таск из playbook, ничего не произойдёт. В Terraform, если удалишь ресурс из кода — он будет уничтожен при следующем `apply`.
