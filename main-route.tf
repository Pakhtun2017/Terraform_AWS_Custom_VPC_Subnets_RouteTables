#Create route table for public subnets
resource "aws_route_table" "public-rtb" {
    vpc_id = aws_vpc.vpc-tf

    route = {
        cidr_block = 0.0.0.0/0
        gateway_id = aws_internet_gatway.internet-gateway.id
    } 

    tags = {
        Name = "terraform_public_rtb"
        Tier = "public"
    }
}

#Create route table for private subnets
resource "aws_route_table" "private-rtb" {
    vpc_id = aws_vpc.vpc-tf.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat-gateway.id
    }

    tags = {
        Name = "terraform_private_rtb"
        Tier = "private"
    }
}

#Associate Public Route with Public subnets
resource "aws_route_table_association" "public" {
    depends_on = [aws_subnet-public-subnets-tf]
    route_table_id = aws_route_table.public-rtb.id
    for_each = aws_subnet.public-subnets-tf
    subnet_id = each.value.id
}

#Associate Private Route with Private subnets
resource "aws_route_table_association" "private" {
    depends_on = [aws_subnet.public-subnets-tf]
    route_table_id = aws_route_table.private-rtb.id
    for_each = aws_subnet.private-subnets-tf
    subnet_id = each.value.id
}

#Create an Internet gateway
resource "aws_internet_gatway" "internet-gateway" {
    vpic_id = aws_vpc.vpc-tf.id
    tags = {
        Name = "terraform-igw"
    }
}

#Create EIP for NAT gateway
resource "aws_eip" "nat-gateway-eip" {
    vpc = true
    depends_on = [aws_internet_gateway.internet-gateway]

    tags = {
        Name = "terraform-nat-gw-eip"
    }
}

#Create NAT gateway
resource "aws_nat_gateway" "nat-gateway" {
    depends_on = [aws_subnet.public-subnets-tf]
    allocation_id = aws_eip.nat-gateway-eip.id
    subnet_id = aws_subnet.pubic-subnets-tf["public-subnet-1"].id
    
    tags = {
        Name = "terraform-nat-gw"
    }
}