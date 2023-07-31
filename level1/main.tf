resource "aws_vpc" "myvpc" {

 cidr_block = "10.0.0.0/16"

  tags = {
    Name = "myvpc"
  }
}

resource "aws_subnet" "public_subnet" {
  count = 2
  vpc_id  = aws_vpc.myvpc.id
  cidr_block = var.public_subnet_cidr[count.index]
  availability_zone =  var.availibility_zone[count.index]
  tags = {
    Name = "public subnet"
  }
}


resource "aws_subnet" "private_subnet" {
  count              = 2
  vpc_id             = aws_vpc.myvpc.id
  cidr_block         = var.private_subnet_cidr[count.index]
  availability_zone  = var.availibility_zone[count.index]
  tags = {
    Name = "private subnet"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "igw"
  }
}

resource "aws_eip" "eip" {
  
  count = length(aws_subnet.public_subnet)
  vpc = true
  
}

resource "aws_nat_gateway" "nat" {
  count         = 2  
  allocation_id = aws_eip.eip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id
  
  tags = {
    Name = "nat"
  }
}


resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "rt_public"
  }
}

resource "aws_route_table_association" "rta_public" {
  count = 2
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_route_table" "rt_private" {
  vpc_id = aws_vpc.myvpc.id
  count = 2

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }

  tags = {
    Name = "rt_private"
  }
}



resource "aws_route_table_association" "rta_private" {
  count = length(aws_subnet.private_subnet)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.rt_private[count.index].id
}







