output "vpc_id" {
  description = "The VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.subnet.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.subnet.private_subnet_ids
}

output "internet_gateway_id" {
  description = "Internet gateway ID"
  value       = module.internet_gateway.igw_id
}

output "nat_gateway_id" {
  description = "NAT gateway ID"
  value       = module.nat_gateway.nat_gateway_id
}

output "key_pair_name" {
  description = "Registered EC2 key pair name"
  value       = module.key_pair.key_name
}

output "instance_private_ips" {
  description = "Private IPs of all EC2 instances"
  value       = module.ec2.private_ips
}

output "instance_public_ips" {
  description = "Public IPs of all EC2 instances"
  value       = module.ec2.public_ips
}

output "nginx_public_ip" {
  description = "Public IP of the Nginx load balancer instance"
  value       = module.ec2.public_ips["nginx-vpc"]
}

output "security_group_lb_id" {
  description = "Nginx load balancer security group ID"
  value       = module.security_group_lb.id
}

output "security_group_node_id" {
  description = "Node application security group ID"
  value       = module.security_group_node.id
}

output "nginx_config" {
  description = "Rendered Nginx configuration"
  value       = module.nginx.nginx_config
}
