variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID to place the NAT gateway in"
  type        = string
}

variable "enable_nat_gateway" {
  description = "Whether to create a NAT gateway"
  type        = bool
  default     = true
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "name" {
  description = "NAT gateway name prefix"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}
