resource "aws_vpc" "vpc-tf" {
  cidr_block           = var.vpc-cidr
  instance_tenancy     = var.tenancy
  enable_dns_hostnames = var.true
  enable_dns_support   = var.true

  tags = {
    Name = "terraform-vpc"
  }
}

#Obtain available availability zones
data "aws_availability_zones" "available-azs" {
  state = "available"
}

#Create public subnets in each available availability zones
resource "aws_subnet" "public-subnets-tf" {
  for_each                = var.public-subnets
  vpc_id                  = aws_vpc.vpc-tf.id
  cidr_block              = cidrsubnet(var.vpc-cidr, 8, each.value + 100)
  availability_zone       = tolist(data.aws_availability_zones.available-azs.names)[each.value - 1]
  map_public_ip_on_launch = true

  tags = {
    Name = "tf-subnet-public-${each.key}"
    Tier = "public"
  }
}

#Create private subnets in each available availability zones
resource "aws_subnet" "private-subnets-tf" {
  for_each                = var.private-subnets
  vpc_id                  = aws_vpc.vpc-tf.id
  cidr_block              = cidrsubnet(var.vpc-cidr, 8, each.value)
  availability_zone       = tolist(data.aws_availability_zones.available-azs.names)[each.value - 1]
  map_public_ip_on_launch = false

  tags = {
    Name = "tf-subnet-private-${each.key}"
    Tier = "private"
  }
}


#Create an Internet gateway
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.vpc-tf.id
  tags = {
    Name = "terraform-igw"
  }
}

#Create EIP for NAT gateway
resource "aws_eip" "nat-gateway-eip" {
  # vpc        = true
  domain     = "vpc"
  depends_on = [aws_internet_gateway.internet-gateway]

  tags = {
    Name = "terraform-nat-gw-eip"
  }
}

#Create NAT gateway
resource "aws_nat_gateway" "nat-gateway" {
  depends_on    = [aws_subnet.public-subnets-tf]
  allocation_id = aws_eip.nat-gateway-eip.id
  subnet_id     = aws_subnet.public-subnets-tf["public-subnet-1"].id

  tags = {
    Name = "terraform-nat-gw"
  }
}


