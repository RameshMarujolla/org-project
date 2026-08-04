locals {
  public_subnets = {
    for subnet in var.public_subnets :
    subnet.name => subnet
  }

  private_subnets = {
    for subnet in var.private_subnets :
    subnet.name => subnet
  }
}

####################################
# VPC
####################################

resource "aws_vpc" "this" {

  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.common_tags,
    {
      Name = var.vpc_name
    }
  )
}

####################################
# Internet Gateway
####################################

resource "aws_internet_gateway" "this" {

  vpc_id = aws_vpc.this.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.vpc_name}-igw"
    }
  )
}

####################################
# Public Subnets
####################################

resource "aws_subnet" "public" {

  for_each = local.public_subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    {
      Name = each.key

      "kubernetes.io/role/elb" = "1"

      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  )
}

####################################
# Private Subnets
####################################

resource "aws_subnet" "private" {

  for_each = local.private_subnets

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = merge(
    var.common_tags,
    {
      Name = each.key

      "kubernetes.io/role/internal-elb" = "1"

      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  )
}

####################################
# Elastic IP
####################################

resource "aws_eip" "nat" {

  domain = "vpc"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.vpc_name}-nat-eip"
    }
  )
}

####################################
# NAT Gateway
####################################

resource "aws_nat_gateway" "this" {

  allocation_id = aws_eip.nat.id

  subnet_id = values(aws_subnet.public)[0].id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.vpc_name}-nat"
    }
  )

  depends_on = [
    aws_internet_gateway.this
  ]
}

####################################
# Public Route Table
####################################

resource "aws_route_table" "public" {

  vpc_id = aws_vpc.this.id

  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.vpc_name}-public-rt"
    }
  )
}

####################################
# Private Route Table
####################################

resource "aws_route_table" "private" {

  vpc_id = aws_vpc.this.id

  route {

    cidr_block = "0.0.0.0/0"

    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.vpc_name}-private-rt"
    }
  )
}

####################################
# Public Associations
####################################

resource "aws_route_table_association" "public" {

  for_each = aws_subnet.public

  subnet_id = each.value.id

  route_table_id = aws_route_table.public.id
}

####################################
# Private Associations
####################################

resource "aws_route_table_association" "private" {

  for_each = aws_subnet.private

  subnet_id = each.value.id

  route_table_id = aws_route_table.private.id
}