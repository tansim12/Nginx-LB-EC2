variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "igw_id" {
  description = "The ID of the internet gateway"
  type        = string
}

variable "nat_gateway_id" {
  description = "The ID of the NAT gateway"
  type        = string
}

variable "enable_nat_gateway" {
  description = "Whether NAT gateway routes are created"
  type        = bool
  default     = true
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
  default     = []
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "name" {
  description = "Route table name prefix"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}
