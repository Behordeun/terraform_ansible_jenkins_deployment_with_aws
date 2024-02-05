# Add a local value
locals {
  azs = data.aws_availability_zones.available.names
}

# Add data source
data "aws_availability_zones" "available" {

}

# Create a random resource
resource "random_id" "random" {
  byte_length = 2
}

# Create a VPC resource
resource "aws_vpc" "mtc_terransible_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "mtc_vpc-${random_id.random.dec}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

# Create a public subnet resource in the VPC
resource "aws_subnet" "mtc_terransible_pub_subnet" {
  count                   = length(local.azs)
  vpc_id                  = aws_vpc.mtc_terransible_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  map_public_ip_on_launch = true
  availability_zone       = local.azs[count.index]

  tags = {
    Name = "mtc-pub-subnet-${count.index + 1}"
  }
}

# Create a private subnet resource in the VPC
resource "aws_subnet" "mtc_terransible_priv_subnet" {
  count                   = length(local.azs)
  vpc_id                  = aws_vpc.mtc_terransible_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, length(local.azs) + count.index)
  map_public_ip_on_launch = false
  availability_zone       = local.azs[count.index]

  tags = {
    Name = "mtc-priv-subnet-${count.index + 1}"
  }
}

# Create an internet gateway resource
resource "aws_internet_gateway" "mtc_terransible_igw" {
  vpc_id = aws_vpc.mtc_terransible_vpc.id

  tags = {
    Name = "mtc-igw-${random_id.random.dec}"
  }
}

# Create a route table resource in the VPC
resource "aws_route_table" "mtc_terransible_pub_rt" {
  vpc_id = aws_vpc.mtc_terransible_vpc.id

  tags = {
    Name = "mtc-pub-rt"
  }
}

# Create a route resource
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.mtc_terransible_pub_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.mtc_terransible_igw.id
  #vpc_peering_connection_id = "pcx-45ff3dc1"
  #depends_on                = [aws_route_table.testing]
}

# Create a default route table
resource "aws_default_route_table" "mtc_terransible_priv_rt" {
  default_route_table_id = aws_vpc.mtc_terransible_vpc.default_route_table_id

  tags = {
    Name = "mtc-priv-rt"
  }
}

# Create a route table association for the public subnet in the VPC
resource "aws_route_table_association" "mtc_terransible_pub_rt-assoc" {
  count          = length(local.azs)
  subnet_id      = aws_subnet.mtc_terransible_pub_subnet.*.id[count.index]
  route_table_id = aws_route_table.mtc_terransible_pub_rt.id
}

# Create a security group resource
resource "aws_security_group" "mtc_terransible_sg" {
  name        = "mtc-pub-sg"
  description = "Security group for public instances"
  vpc_id      = aws_vpc.mtc_terransible_vpc.id
}

# Create an ingress connection
resource "aws_security_group_rule" "ingress_all" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = var.access_ip
  security_group_id = aws_security_group.mtc_terransible_sg.id
}

# Create an egress connection
resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.mtc_terransible_sg.id
}
