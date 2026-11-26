variable "instances" {
  description = "Map of EC2 instance configurations"
  type = map(object({
    role                   = string
    instance_type          = string
    ami                    = string
    subnet_id              = string
    security_group_ids     = list(string)
    user_data              = optional(string, "")
    termination_protection = optional(bool, false)
    monitoring             = optional(bool, true)
    tags                   = optional(map(string), {})
  }))
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}

variable "key_name" {
  description = "The EC2 key pair name"
  type        = string
}
