terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
  
   tags = {
    Name = "myvpc"
   }
}

resource "aws_subnet" "publicsubnet" {
  count = 2
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = var.public_subnet_cidr[count.index]
  availability_zone = var.availibility_zone[count.index]
  tags = {
    Name = "publicsubnet"
  }
}

resource "aws_subnet" "privatesubnet" {
  count = 2
  vpc_id = aws_vpc.myvpc.id
  cidr_block = var.private_subnet_cidr[count.index]
   availability_zone = var.availibility_zone[count.index]
  
   tags = {
     Name = "privatesubnet"
   }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "igw"
  }
}

resource "aws_eip" "my_eip" {
  count = 2
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  count         = 2  
  allocation_id = aws_eip.my_eip[count.index].id
  subnet_id     = aws_subnet.privatesubnet[count.index].id
  
  tags = {
    Name = "nat"
  }
}

resource "aws_route_table" "rtpublic" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rta_public" {
  count = length(aws_subnet.publicsubnet)
  
  subnet_id      = aws_subnet.publicsubnet[count.index].id
  route_table_id = aws_route_table.rtpublic.id
}


resource "aws_route_table" "rtprivate" {
  vpc_id = aws_vpc.myvpc.id
  count = 2
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }
}

resource "aws_route_table_association" "rta_private" {
    count =length(aws_subnet.privatesubnet)
    subnet_id = aws_subnet.privatesubnet[count.index].id
    route_table_id = aws_route_table.rtprivate[count.index].id
}


