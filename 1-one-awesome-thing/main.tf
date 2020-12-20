provider "aws" {
  region     = "us-east-1"
}

resource "aws_instance" "web_server" {
  ami                    = "ami-04d29b6f966df1537"
  instance_type          = "t2.micro"

  user_data = <<-EOF
              #!/bin/bash
              sudo yum -y install httpd
              sudo echo "Hello World" > /var/www/html/index.html
              sudo systemctl start httpd
              EOF

  tags = {
    Name = "Web Server"
  }
}