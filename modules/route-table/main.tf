resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  tags = merge(var.common_tags, {
    Name        = "${var.name}-public-rt-${var.environment}"
    Environment = var.environment
    Tier        = "public"
  })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.igw_id
}

resource "aws_route_table_association" "public" {
  for_each       = toset(var.public_subnet_ids)
  subnet_id      = each.value
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count = length(var.private_subnet_ids) > 0 ? 1 : 0

  vpc_id = var.vpc_id

  tags = merge(var.common_tags, {
    Name        = "${var.name}-private-rt-${var.environment}"
    Environment = var.environment
    Tier        = "private"
  })
}

resource "aws_route" "private_nat" {
  count = var.enable_nat_gateway && length(var.private_subnet_ids) > 0 ? 1 : 0

  route_table_id         = aws_route_table.private[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.nat_gateway_id
}

resource "aws_route_table_association" "private" {
  for_each       = toset(var.private_subnet_ids)
  subnet_id      = each.value
  route_table_id = aws_route_table.private[0].id
}
