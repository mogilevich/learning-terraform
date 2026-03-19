output "environment" {
  value = local.environment
}

output "server_count" {
  value = length(local.servers_data.servers)
}

output "web_servers" {
  value = [for s in local.servers_data.servers : s.name if s.role == "web"]
}


output "db_config_path" {
  value = data.local_file.db_config.filename
}
