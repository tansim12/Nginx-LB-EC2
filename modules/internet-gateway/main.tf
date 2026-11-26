resource "aws_internet_gateway" "this" {
  tags = merge(var.common_tags, {
    Name        = "${var.name}-igw-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_internet_gateway_attachment" "this" {
  vpc_id              = var.vpc_id
  internet_gateway_id = aws_internet_gateway.this.id
}
