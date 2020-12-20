# Our AWS provider - Tells Terraform what we want to interact with
provider "aws" {
  region     = "us-east-1"
}

# Our first resource - An AWS instance called "Web_server"
resource "aws_instance" "web_server" {
  # The specific Amazon Machine Image (template) we wish to use - Amazon Linux 2 x64
  ami                    = "ami-04d29b6f966df1537"
  instance_type          = "t2.micro"

  # Commands to execute on instance after build
  # Deploy a basic web server
  user_data = <<-EOF
              #!/bin/bash
              sudo yum -y install httpd
              sudo echo "Hello World" > /var/www/html/index.html
              sudo systemctl start httpd
              EOF

  # Add a Name tag for easy naming
  tags = {
    Name = "Web Server"
  }
}