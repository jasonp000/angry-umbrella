variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 80
}

provider "aws" {
  #access_key = var.access_key
  #secret_key = var.secret_key
  #region     = var.region
  region     = "us-east-1"
  #version    = "3.21.0"
}

resource "aws_instance" "web_server" {
  ami                    = "ami-04d29b6f966df1537"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]
  key_name               = module.keypair.key_name
  #private_key            = module.keypair.private_key_pem

  user_data = <<-EOF
              #!/bin/bash
              sudo yum -y update
              sudo yum -y install httpd
              sudo echo "Hello World" > /var/www/html/index.html
              sudo systemctl enable httpd
              sudo systemctl start httpd
              sudo reboot
              EOF

  tags = {
    Name = "Web Server"
  }
}

resource "aws_security_group" "instance" {
  name = "Inbound Web and SSH, Outbound all"
  description = "Traffic for web server"
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Web port 8080/tcp"
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

module "keypair" {
  source  = "mitchellh/dynamic-keys/aws"
  version = "2.0.0"
  path    = "${path.root}/keys"
  name    = "mykeypair-key"
}

output "public_ip" {
  value = aws_instance.web_server.*.public_ip
  description = "Public IP Address"
}

output "public_dns" {
  value = aws_instance.web_server.*.public_dns
}