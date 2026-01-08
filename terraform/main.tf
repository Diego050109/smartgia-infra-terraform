locals {
  env    = terraform.workspace
  prefix = "${var.project_name}-${local.env}"

  # Redes por entorno (VPC y Subnets)
  network = {
    default = {
      vpc_cidr       = "10.0.0.0/16"
      public_1_cidr  = "10.0.1.0/24"
      public_2_cidr  = "10.0.2.0/24"
      private_1_cidr = "10.0.11.0/24"
      private_2_cidr = "10.0.12.0/24"
    }
    qa = {
      vpc_cidr       = "10.10.0.0/16"
      public_1_cidr  = "10.10.1.0/24"
      public_2_cidr  = "10.10.2.0/24"
      private_1_cidr = "10.10.11.0/24"
      private_2_cidr = "10.10.12.0/24"
    }
    prod = {
      vpc_cidr       = "10.20.0.0/16"
      public_1_cidr  = "10.20.1.0/24"
      public_2_cidr  = "10.20.2.0/24"
      private_1_cidr = "10.20.11.0/24"
      private_2_cidr = "10.20.12.0/24"
    }
  }

  # Si el workspace no es qa/prod, usa default
  net = lookup(local.network, local.env, local.network["default"])

  tags = {
    Project = var.project_name
    Env     = local.env
    Owner   = "SMARTGIA"
  }
}

# -----------------------------
# VPC
# -----------------------------
resource "aws_vpc" "main" {
  cidr_block           = local.net.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.tags, {
    Name = "${local.prefix}-vpc"
  })
}

# -----------------------------
# Internet Gateway
# -----------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.tags, {
    Name = "${local.prefix}-igw"
  })
}

# -----------------------------
# Public Subnets
# -----------------------------
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.net.public_1_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = merge(local.tags, {
    Name = "${local.prefix}-public-1"
  })
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.net.public_2_cidr
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = merge(local.tags, {
    Name = "${local.prefix}-public-2"
  })
}

# -----------------------------
# Private Subnets
# -----------------------------
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.net.private_1_cidr
  availability_zone = "${var.aws_region}a"

  tags = merge(local.tags, {
    Name = "${local.prefix}-private-1"
  })
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.net.private_2_cidr
  availability_zone = "${var.aws_region}b"

  tags = merge(local.tags, {
    Name = "${local.prefix}-private-2"
  })
}

# -----------------------------
# Public Route Table
# -----------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(local.tags, {
    Name = "${local.prefix}-public-rt"
  })
}

# -----------------------------
# Route Table Associations (Public)
# -----------------------------
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}
