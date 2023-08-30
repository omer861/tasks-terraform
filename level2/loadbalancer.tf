
resource "aws_security_group" "lb_sg" {
  name        = "lb-sg"
  description = "Security group for Load Balancer"
  vpc_id      = data.terraform_remote_state.level1.outputs.vpc_id
  ingress {
    description = "HTTP from everywehre"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "load-balancer"
  }
}


resource "aws_lb" "aws_lb" {
  name               = "lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = data.terraform_remote_state.level1.outputs.public_subnet

  tags = {
    Name = "aws_lb"
  }
}


resource "aws_lb_target_group" "my_target_group" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.level1.outputs.vpc_id
 
  health_check {
    enabled             = true
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 10
    matcher             = 200
  }
}


resource "aws_lb_listener" "lb_list" {
  load_balancer_arn = aws_lb.aws_lb.arn
port = 80
  default_action {
    target_group_arn = aws_lb_target_group.my_target_group.arn
    type             = "forward"
   
  }
}