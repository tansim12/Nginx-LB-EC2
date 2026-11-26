output "nginx_config" {
  description = "Rendered Nginx configuration"
  value = templatefile(var.template_path, {
    upstream_servers      = var.upstream_servers
    listen_port           = var.listen_port
    upstream_name         = var.upstream_name
    upstream_algorithm    = var.upstream_algorithm
    server_name           = var.server_name
    proxy_connect_timeout = var.proxy_connect_timeout
    proxy_read_timeout    = var.proxy_read_timeout
    proxy_send_timeout    = var.proxy_send_timeout
    health_check_uri      = var.health_check_uri
  })
}
