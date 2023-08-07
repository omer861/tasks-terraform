data "aws_ami" "amazonlinux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"]
}

resource "aws_security_group" "public_sg" {
  name        = "public_sg"
  description = "allows public traffic"
  vpc_id      = data.terraform_remote_state.level1.outputs.vpc_id

  ingress {
    description = "SHH from home office"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["124.123.162.52/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  
  tags = {
    Name = "public_sg"
  }
}

resource "aws_instance" "public" {
  ami                         = data.aws_ami.amazonlinux.id
  instance_type               = "t2.micro"
  subnet_id                   = data.terraform_remote_state.level1.outputs.public_subnet[0]
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  key_name                    = "awskey"
  associate_public_ip_address = true

  tags = {
    Name = "public_instance"
  }
}


resource "aws_security_group" "private_sg" {
  name        = "private_sg"
  description = "private_sg inbound traffic"
  vpc_id      = data.terraform_remote_state.level1.outputs.vpc_id

  
  ingress {
    description      = "ssh rule"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [data.terraform_remote_state.level1.outputs.vpc_cidr]
  }
  

  ingress {
    description      = "http rule"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "sg group-private"
  }
}


resource "aws_instance" "web-private" {
  count = 2
  ami                         = data.aws_ami.amazonlinux.id
  instance_type               = "t2.micro"
  subnet_id                   = data.terraform_remote_state.level1.outputs.private_subnet[count.index]
  vpc_security_group_ids      = [aws_security_group.private_sg.id]
  key_name                    = "awskey"
  user_data                   = file("host.sh")
 tags = {
  Name = "private_instance"
  }
}


