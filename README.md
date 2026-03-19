# Learning Terraform

Практический курс Terraform для сисадминов знакомых с Ansible.
Все уроки работают локально — нужен только Docker.

## Требования

- [Terraform](https://developer.hashicorp.com/terraform/install) 1.0+
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) для Mac

## Автодополнение в zsh

```bash
# Добавить в ~/.zshrc:
complete -C $(which terraform) terraform

# Или через oh-my-zsh (добавить terraform в plugins):
plugins=(... terraform)
```

После `source ~/.zshrc` работает автодополнение команд и флагов по Tab.

## Уроки

| # | Тема | Что изучаем |
| --- | --- | --- |
| [01-providers](01-providers/) | Провайдеры | `terraform init`, Docker провайдер, первый `apply` |
| [02-resources](02-resources/) | Ресурсы | Зависимости, replace vs destroy, `-target` |
| [03-variables](03-variables/) | Переменные | `variable`, `locals`, `outputs`, `tfvars`, приоритеты |
| [04-local-random](04-local-random/) | local и random | `templatefile()`, `random_password`, `sensitive`, `keepers` |
| [05-state](05-state/) | State | Как работает state, `terraform state` команды, refresh |
| [06-data-sources](06-data-sources/) | Data sources | `data {}` vs `resource {}`, `jsondecode()`, for-выражения |
| [07-modules](07-modules/) | Модули | Переиспользование, inputs/outputs модуля, аналог ролей Ansible |

## Рабочий цикл в каждом уроке

```bash
cd NN-lesson
terraform init      # один раз — скачать провайдеры и зарегистрировать модули
terraform plan      # превью: что изменится
terraform apply     # применить изменения
terraform destroy   # убрать всё за собой
```

> `terraform init` нужен повторно если добавил новый `module {}` блок или сменил версию провайдера.
