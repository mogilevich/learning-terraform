# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

This is a Terraform learning repository for experimenting with infrastructure-as-code concepts.

## Common Commands

- `terraform init` — initialize working directory and download providers
- `terraform plan` — preview changes before applying
- `terraform apply` — apply infrastructure changes
- `terraform destroy` — tear down managed infrastructure
- `terraform fmt` — format .tf files to canonical style
- `terraform validate` — check configuration syntax and consistency

## Conventions

- Use `terraform fmt` before committing to ensure consistent formatting
- Keep provider versions pinned in `versions.tf` or `terraform` block constraints
- Use variables and outputs rather than hardcoding values
- Store state configuration (backend) separately from resource definitions
