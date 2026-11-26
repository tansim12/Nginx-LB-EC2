resource "aws_instance" "this" {
  for_each               = var.instances
  ami                    = each.value.ami
  instance_type          = each.value.instance_type
  subnet_id              = each.value.subnet_id
  vpc_security_group_ids = each.value.security_group_ids
  key_name               = var.key_name
  user_data              = each.value.user_data
  monitoring             = each.value.monitoring

  tags = merge(var.common_tags, {
    Name        = "${each.key}-${var.environment}"
    Environment = var.environment
    Role        = each.value.role
  }, each.value.tags)

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
