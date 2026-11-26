resource "aws_subnet" "public" {
  for_each                = var.public_subnet_cidrs
  vpc_id                  = var.vpc_id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(var.common_tags, {
    Name        = "${var.name}-public-${each.key}-${var.environment}"
    Environment = var.environment
    Tier        = "public"
  })
}

resource "aws_subnet" "private" {
  for_each                = var.create_private_subnets ? var.private_subnet_cidrs : {}
  vpc_id                  = var.vpc_id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = false

  tags = merge(var.common_tags, {
    Name        = "${var.name}-private-${each.key}-${var.environment}"
    Environment = var.environment
    Tier        = "private"
  })
}
