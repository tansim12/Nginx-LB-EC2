variable "key_name" {
  description = "Name of the EC2 key pair to register in AWS"
  type        = string
}

variable "public_key_path" {
  description = "Filesystem path to the existing SSH public key"
  type        = string
}
