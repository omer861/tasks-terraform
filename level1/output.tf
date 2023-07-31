output "vpc_id" {
  value = aws_vpc.myvpc.id
}


output "vpc_cidr" {
  value = aws_vpc.myvpc.cidr_block
}

output "public_subnet" {
    value = aws_subnet.public_subnet[*].id
}

output "private_subnet" {
    value = aws_subnet.private_subnet[*].id
}


output "igw" {
    value = aws_internet_gateway.igw.id 
  
}

output "nat" {
    value = aws_nat_gateway.nat[*].id
  
}

output "rt_public" {
    value = aws_route_table.rt_public.id
  
}

output "rt_private" {
    value = aws_route_table.rt_private[*].id
  
}




