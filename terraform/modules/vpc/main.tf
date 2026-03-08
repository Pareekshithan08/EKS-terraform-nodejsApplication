resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet)

  vpc_id = aws_vpc.main.id

  cidr_block = var.public_subnet[count.index]
  
  availability_zone = var.azs[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index}"

    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet)

  vpc_id = aws_vpc.main.id

  cidr_block = var.private_subnet[count.index]

  availability_zone = var.azs[count.index]

  tags = {
    Name = "private-subnet-${count.index}"

    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "eks-igw"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  
  allocation_id = aws_eip.nat.id
  
  subnet_id = aws_subnet.public[0].id

  tags = {
    Name = "eks-nat"
  }
}

resource "aws_route_table" "public" {
  
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route" "public_internet_access" {
  
  route_table_id = aws_route_table.public.id

  destination_cidr_block = "0.0.0.0/0"

  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  
  count = length(aws_subnet.public)

  subnet_id = aws_subnet.public[count.index].id

  route_table_id = aws_route_table.public.id

}

resource "aws_route_table" "private" {
  
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route" "private_nat_access" {
  
  route_table_id = aws_route_table.private.id

  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "private" {
  
  count = length(aws_subnet.private)

  subnet_id = aws_subnet.private[count.index]

  route_table_id = aws_route_table.private.id
}

