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
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet)

  vpc_id = aws_vpc.main.id

  cidr_block = var.private_subnet[count.index]

  availability_zone = var.azs[count.index]

  tags = {
    Name = "private-subnet-${count.index}"
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

