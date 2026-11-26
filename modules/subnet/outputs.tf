output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = { for k, v in aws_subnet.public : k => v.id }
}

output "public_subnet_cidrs" {
  description = "CIDRs of the public subnets"
  value       = var.public_subnet_cidrs
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = { for k, v in aws_subnet.private : k => v.id }
}

output "private_subnet_cidrs" {
  description = "CIDRs of the private subnets"
  value       = var.private_subnet_cidrs
}

output "public_subnet_id_list" {
  description = "List of public subnet IDs"
  value       = values(aws_subnet.public)[*].id
}

output "private_subnet_id_list" {
  description = "List of private subnet IDs"
  value       = values(aws_subnet.private)[*].id
}
