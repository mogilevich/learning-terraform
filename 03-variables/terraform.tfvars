# ============================================================
# terraform.tfvars — файл значений переменных
# ============================================================
#
# Аналогия: group_vars/all.yml в Ansible.
# Terraform автоматически загружает этот файл (по имени).
#
# Приоритет значений (от низшего к высшему):
#   1. default в variable {}          — как defaults/main.yml в роли
#   2. terraform.tfvars               — как group_vars  ← мы тут
#   3. *.auto.tfvars                  — автоподхват
#   4. -var-file=...                  — как -e @vars.yml
#   5. -var="key=value"              — как -e key=value
#   6. TF_VAR_name (env)             — как ANSIBLE_VAR_name

environment = "dev"

# Раскомментируй чтобы переопределить defaults:
# container_name = "my-custom-nginx"
# external_port  = 9090
