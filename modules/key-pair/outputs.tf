output "key_name" {
  description = "The registered key pair name"
  value       = aws_key_pair.existing.key_name
}

output "key_id" {
  description = "The key pair ID"
  value       = aws_key_pair.existing.id
}

output "public_key_fingerprint" {
  description = "The fingerprint of the public key"
  value       = aws_key_pair.existing.fingerprint
}
