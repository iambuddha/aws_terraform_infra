provider "aws" {
  region = "us-east-1"
}

resource "aws_launch_configuration" "my-test-launch-config" {
  image_id = "ami-0c94855ba95c71c99"
  instance_type = var.instance_type
  security_groups = [aws_security_group.my-asg-sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum -y install httpd
              echo "Hello from Terraform" > /var/www/html/index.html
              service httpd start
              chkconfig httpd on
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.my-test-launch-config.name
  vpc_zone_identifier = [var.subnet1, var.subnet2]
  target_group_arns = [var.alb_target_group_arn]
  health_check_type = "ELB"
  max_size = 10
  min_size = 2

  tag {
    key = "Name"
    propagate_at_launch = true
    value = "my-test-asg"
  }
}

#resource "aws_autoscaling_attachment" "asg_attachment_elb" {
#  autoscaling_group_name = aws_autoscaling_group.example.id
#  alb_target_group_arn = var.alb_target_group_arn
#}

resource "aws_security_group" "my-asg-sg" {
  name = "my-asg-sg"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "inbound_ssh" {
  from_port = 22
  protocol = "tcp"
  security_group_id = aws_security_group.my-asg-sg.id
  to_port = 22
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "inbound_http" {
  from_port = 80
  protocol = "tcp"
  security_group_id = aws_security_group.my-asg-sg.id
  to_port = 80
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "outbound_all" {
  from_port = 0
  protocol = "-1"
  security_group_id = aws_security_group.my-asg-sg.id
  to_port = 0
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}