resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? 1 : 0

  domain = "vpc"

  tags = merge(var.common_tags, {
    Name        = "${var.name}-nat-eip-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_nat_gateway" "this" {
  count             = var.enable_nat_gateway ? 1 : 0
  allocation_id     = aws_eip.nat[0].id
  subnet_id         = var.public_subnet_id
  connectivity_type = "public"

  tags = merge(var.common_tags, {
    Name        = "${var.name}-nat-${var.environment}"
    Environment = var.environment
  })
}
