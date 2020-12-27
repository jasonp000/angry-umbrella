variable "server_port" {}
variable "elb_port" {}
variable "ssh_port" {}
variable "ami" {}
variable "instance_type" {}
variable "subnet_id" {}
variable "identity" {}
variable "vpc_security_group_ids" {
  type = list
}

resource "aws_security_group" "instance" {
  name          = "Inbound Web and SSH, Outbound all"
  description   = "Traffic for web server"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Web port ${var.server_port}/tcp"
  }
  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH port ${var.ssh_port}/tcp"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Outbound access to all"
  }
}

resource "aws_launch_configuration" "example" {
  image_id        = var.ami
  instance_type   = var.instance_type
  security_groups = [aws_security_group.instance.id]
  key_name        = module.keypair.key_name

  user_data = <<-EOF
              #!/bin/bash
              sudo yum -y update
              sudo yum -y install httpd
              sudo echo "Hello World" > /var/www/html/index.html
              sudo systemctl enable httpd
              sudo reboot
              EOF
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  availability_zones   = data.aws_availability_zones.all.names
  load_balancers       = [aws_elb.example.name]
  health_check_type    = "ELB"
  
  #min size must be 1 for aws educate account
  min_size              = 1
  desired_capacity      = 2
  max_size              = 3

  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}

resource "aws_elb" "example" {
  name                  = "terraform-asg-example"
  security_groups       = [aws_security_group.elb.id]
  availability_zones    = data.aws_availability_zones.all.names
  health_check {
    target              = "HTTP:${var.server_port}/"
    interval            = 30
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  # This adds a listener for incoming HTTP requests.
  listener {
    lb_port             = var.elb_port
    lb_protocol         = "http"
    instance_port       = var.server_port
    instance_protocol   = "http"
  }
}

resource "aws_security_group" "elb" {
  name = "terraform-example-elb"

  # Allow all outbound traffic
  egress {
    from_port           = 0
    to_port             = 0
    protocol            = "-1"
    cidr_blocks         = ["0.0.0.0/0"]
  }

  # Inbound HTTP from anywhere
  ingress {
    from_port           = var.elb_port
    to_port             = var.elb_port
    protocol            = "tcp"
    cidr_blocks         = ["0.0.0.0/0"]
  }
}

output "clb_dns_name" {
  value                 = aws_elb.example.dns_name
  description           = "The domain name of the load balancer"
}