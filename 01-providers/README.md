# Урок 01: Провайдеры и terraform init

## Концепция

В Ansible ты ставишь модули через `ansible-galaxy install`. В Terraform — похожий механизм:
**провайдер** — это плагин, который умеет управлять конкретной системой (AWS, Docker, файлами и т.д.).

Команда `terraform init` скачивает нужные провайдеры — как `ansible-galaxy install -r requirements.yml`.

## Что делает этот пример

- Подключает провайдер `kreuzwerker/docker` — он умеет управлять Docker-контейнерами и образами
- Скачивает образ `nginx:alpine`
- Запускает контейнер с nginx на порту 8080

## Команды

```bash
# 1. Инициализация — скачает провайдер Docker
terraform init

# 2. Посмотреть что Terraform собирается сделать (как --check в Ansible)
terraform plan

# 3. Применить — создать ресурсы
terraform apply

# 4. Проверить что контейнер работает
docker ps
curl http://localhost:8080

# 5. Удалить всё что создали
terraform destroy
```

## Что изучить в этом уроке

1. Открой `main.tf` — прочитай комментарии
2. Выполни команды выше по порядку
3. Обрати внимание на файлы, которые появятся после `terraform init`:
   - `.terraform/` — скачанные провайдеры (как `~/.ansible/collections/`)
   - `.terraform.lock.hcl` — lock-файл версий (как `requirements.txt`)
4. После `terraform apply` появится `terraform.tfstate` — об этом подробно в уроке 04
