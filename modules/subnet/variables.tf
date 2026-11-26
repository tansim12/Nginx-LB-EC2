variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "name" {
  description = "Subnet name prefix"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}

variable "availability_zones" {
  description = "List of availability zones to create subnets in"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Map of availability zone to public subnet CIDR"
  type        = map(string)
}

variable "private_subnet_cidrs" {
  description = "Map of availability zone to private subnet CIDR"
  type        = map(string)
  default     = {}
}

variable "create_private_subnets" {
  description = "Whether to create private subnets"
  type        = bool
  default     = true
}

variable "map_public_ip_on_launch" {
  description = "Auto-assign public IP on launch for public subnets"
  type        = bool
  default     = true
}
