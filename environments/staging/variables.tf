variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "staging"
}

variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
  default     = "lab1-lb"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.1.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones (staging uses 2 for HA)"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
}

variable "public_subnet_cidrs" {
  description = "Map of AZ to public subnet CIDR"
  type        = map(string)
  default = {
    "ap-southeast-1a" = "10.1.1.0/24"
    "ap-southeast-1b" = "10.1.2.0/24"
  }
}

variable "private_subnet_cidrs" {
  description = "Map of AZ to private subnet CIDR"
  type        = map(string)
  default = {
    "ap-southeast-1a" = "10.1.10.0/24"
    "ap-southeast-1b" = "10.1.20.0/24"
  }
}

variable "create_private_subnets" {
  description = "Create private subnets"
  type        = bool
  default     = true
}

variable "enable_nat_gateway" {
  description = "Enable NAT gateway"
  type        = bool
  default     = true
}

variable "ami" {
  description = "EC2 AMI ID (must be a valid ap-southeast-1 AMI)"
  type        = string
}

variable "nginx_instance_type" {
  description = "Nginx EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "node_instance_type" {
  description = "Node app EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
  default     = "my-key-pair"
}

variable "public_key_path" {
  description = "Path to existing SSH public key"
  type        = string
  default     = "~/.ssh/my-key-pair.pub"
}

variable "ssh_user" {
  description = "SSH user for EC2 instances"
  type        = string
  default     = "ubuntu"
}

variable "trusted_ssh_cidr" {
  description = "CIDR allowed for SSH access"
  type        = string
  default     = "0.0.0.0/0"
}

variable "lb_algorithm" {
  description = "Nginx load balancing algorithm"
  type        = string
  default     = "least_conn"
}

variable "deploy_nginx_config" {
  description = "Attempt to deploy nginx config via SSH after instance creation"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default = {
    ManagedBy   = "Terraform"
    Project     = "Lab1-LB"
    Environment = "staging"
    Owner       = "DevOps"
  }
}
