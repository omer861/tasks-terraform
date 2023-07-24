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
  description = "public_sg inbound traffic"
   vpc_id      = data.terraform_remote_state.level1.outputs.vpc_id

  ingress {
    description      = "ssh rule"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  ingress {
    description      = "http rule"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.env_code[0]}-sg group-public"
  }
}

resource "aws_instance" "web-public" {
  ami                         = data.aws_ami.amazonlinux.id
  instance_type               = "t2.micro"
  subnet_id                   = data.terraform_remote_state.level1.outputs.public_subnet[0]
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  key_name                    = "awskey"
  associate_public_ip_address = true
  user_data                   = file("2048.sh")
 tags = {
  Name = "${var.env_code[0]}-public"
  }
}





resource "aws_security_group" "private_sg" {
  name        = "private_sg"
  description = "public_sg inbound traffic"
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
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.env_code[0]}-sg group-public-private"
  }
}


resource "aws_instance" "web-private" {
  ami                         = data.aws_ami.amazonlinux.id
  instance_type               = "t2.micro"
  subnet_id                   = data.terraform_remote_state.level1.outputs.private_subnet[0]
  vpc_security_group_ids      = [aws_security_group.private_sg.id]
  key_name                    = "awskey"
 tags = {
  Name = "${var.env_code[0]}-private"
  }
}


