# A variable for our server port
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 80
}

# Our provider - AWS
provider "aws" {
  region     = "us-east-1"
}

# Set up the keypair module for dynamic SSH key creation
module "keypair" {
  source  = "mitchellh/dynamic-keys/aws"
  version = "2.0.0"
  path    = "${path.root}/keys"
  name    = "mykeypair-key"
}

# Create a security group for our new instance to only allow web and SSH traffic
resource "aws_security_group" "instance" {
  name = "Inbound Web and SSH, Outbound all"
  description = "Traffic for web server"
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Web port ${var.server_port}/tcp"
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH port 22/tcp"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Outbound access to all"
  }
}

# Create a web server instance with some keys and better security groups
resource "aws_instance" "web_server" {
  ami                    = "ami-04d29b6f966df1537"
  instance_type          = "t2.micro"
  key_name               = module.keypair.key_name
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum -y update
              sudo yum -y install httpd
              sudo echo "Hello World" > /var/www/html/index.html
              sudo systemctl enable httpd
              #sudo systemctl start httpd
              sudo reboot
              EOF

  tags = {
    Name = "Web Server"
  }
}

output "public_ip" {
  value = aws_instance.web_server.public_ip
  description = "Public IP Address"
}

output "public_dns" {
  value = aws_instance.web_server.*.public_dns
  description = "Publid DNS address"
}