output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "The ID of the private route table"
  value       = length(var.private_subnet_ids) > 0 ? aws_route_table.private[0].id : null
}
