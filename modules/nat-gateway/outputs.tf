output "nat_gateway_id" {
  description = "The ID of the NAT gateway"
  value       = aws_nat_gateway.this[0].id
}

output "eip_id" {
  description = "The ID of the elastic IP"
  value       = aws_eip.nat[0].id
}

output "eip_allocation_id" {
  description = "The allocation ID of the elastic IP"
  value       = aws_eip.nat[0].id
}

output "nat_gateway_enabled" {
  description = "Whether the NAT gateway was created"
  value       = var.enable_nat_gateway
}
