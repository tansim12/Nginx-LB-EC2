variable "upstream_servers" {
  description = "List of backend servers for the Nginx upstream block"
  type = list(object({
    name = string
    ip   = string
    port = number
  }))
}

variable "listen_port" {
  description = "Nginx listen port"
  type        = number
  default     = 80
}

variable "upstream_name" {
  description = "Name of the upstream block"
  type        = string
  default     = "node_backend"
}

variable "upstream_algorithm" {
  description = "Load balancing algorithm (least_conn, ip_hash, or empty for round_robin)"
  type        = string
  default     = "least_conn"
}

variable "server_name" {
  description = "Server name for the Nginx server block"
  type        = string
  default     = "_"
}

variable "template_path" {
  description = "Path to the nginx.conf template file"
  type        = string
}

variable "proxy_connect_timeout" {
  description = "Nginx proxy connect timeout (seconds)"
  type        = number
  default     = 30
}

variable "proxy_read_timeout" {
  description = "Nginx proxy read timeout (seconds)"
  type        = number
  default     = 60
}

variable "proxy_send_timeout" {
  description = "Nginx proxy send timeout (seconds)"
  type        = number
  default     = 60
}

variable "health_check_uri" {
  description = "Upstream health check URI"
  type        = string
  default     = "/health"
}
