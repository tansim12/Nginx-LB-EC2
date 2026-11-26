output "instance_ids" {
  description = "IDs of the EC2 instances"
  value       = { for k, v in aws_instance.this : k => v.id }
}

output "private_ips" {
  description = "Private IPs of the EC2 instances"
  value       = { for k, v in aws_instance.this : k => v.private_ip }
}

output "public_ips" {
  description = "Public IPs of the EC2 instances"
  value       = { for k, v in aws_instance.this : k => v.public_ip }
}

output "instance_map" {
  description = "Full map of instance attributes"
  value       = aws_instance.this
}
