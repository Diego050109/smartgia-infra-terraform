# Elastic IP para NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = merge(local.tags, {
    Name = "${local.prefix}-nat-eip"
  })
}

# NAT Gateway en la subnet pública 1
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_1.id

  tags = merge(local.tags, {
    Name = "${local.prefix}-nat"
  })

  depends_on = [aws_internet_gateway.igw]
}

# Route Table privada
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = merge(local.tags, {
    Name = "${local.prefix}-private-rt"
  })
}

# Asociar route table privada a subnets privadas
resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}
