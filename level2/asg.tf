resource "aws_launch_template" "launch_template" {
  name          = "launch-template"
  image_id      = data.aws_ami.amazonlinux.id
  instance_type = "t2.micro"
  key_name      = "awskey"
  
  user_data = base64encode(<<EOF
#!/bin/bash
yum update -y
yum install -y httpd
echo "Hello from $(hostname)" > /var/www/html/index.html
systemctl start httpd && systemctl enable httpd
EOF
  )
  
  network_interfaces {
    associate_public_ip_address = true
  }

  security_group_names = [aws_security_group.public_sg.name]
}

resource "aws_autoscaling_group" "asg" {
  name             = "my-asg"
  desired_capacity = 2
  max_size         = 5
  min_size         = 1
  
  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }

  vpc_zone_identifier = [data.terraform_remote_state.level1.outputs.myvpc.id]
  target_group_arns = [aws_lb_target_group.my_target_group.arn]
  

  tag {
    key                 = "my-asg"
    value               = "aws_autoscaling_group"
    propagate_at_launch = true
  }
}
