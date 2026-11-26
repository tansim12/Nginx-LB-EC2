resource "aws_security_group" "this" {
  name        = "${var.name}-${var.environment}"
  description = var.description
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name        = "${var.name}-sg-${var.environment}"
    Environment = var.environment
  })
}

# Ingress rules sourced from CIDR blocks
resource "aws_security_group_rule" "ingress_cidr" {
  for_each        = { for i, r in var.ingress_cidr : i => r }
  type            = "ingress"
  from_port       = each.value.from_port
  to_port         = each.value.to_port
  protocol        = each.value.protocol
  cidr_blocks     = each.value.cidr_blocks
  security_group_id = aws_security_group.this.id
  description     = each.value.description
}

# Ingress rules sourced from other security groups
resource "aws_security_group_rule" "ingress_sg" {
  for_each                = { for i, r in var.ingress_sg : i => r }
  type                    = "ingress"
  from_port               = each.value.from_port
  to_port                 = each.value.to_port
  protocol                = each.value.protocol
  source_security_group_id = each.value.source_security_group_id
  security_group_id       = aws_security_group.this.id
  description             = each.value.description
}

# Egress rules to CIDR blocks
resource "aws_security_group_rule" "egress" {
  for_each        = { for i, r in var.egress_cidr : i => r }
  type            = "egress"
  from_port       = each.value.from_port
  to_port         = each.value.to_port
  protocol        = each.value.protocol
  cidr_blocks     = each.value.cidr_blocks
  security_group_id = aws_security_group.this.id
  description     = each.value.description
}
