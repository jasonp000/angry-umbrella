variable "access_key" {}
variable "secret_key" {}
variable "aws_session_token" {}
variable "region" {
  default = "us-east-1"
}
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

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  token      = var.aws_session_token
  region     = var.region
}

module "elb" {
  source = "./elb"

  server_port            = var.server_port
  elb_port               = var.elb_port
  ssh_port               = var.ssh_port
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  identity               = var.identity
  vpc_security_group_ids = var.vpc_security_group_ids
}

output "dns_name" {
  value                 = module.elb.clb_dns_name
  description           = "The domain name of the load balancer"
}