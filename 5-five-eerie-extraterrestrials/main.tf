variable "access_key" {}
variable "secret_key" {}
variable "aws_session_token" {}
variable "region" {
  default = "us-east-1"
}

data "aws_availability_zones" "all" {}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  token      = var.aws_session_token
  region     = var.region
}

module "keypair" {
  source                = "mitchellh/dynamic-keys/aws"
  version               = "2.0.0"
  path                  = "${path.root}/keys"
  name                  = "mykeypair-key"
}