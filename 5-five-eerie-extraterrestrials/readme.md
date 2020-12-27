# #5 - Five Eerie Extraterrestrials Evan - Modularize, modernize, and more

Our single `main.tf` configuration file can be separated out into modules to better organize your configuration. This makes your code easier to read and reusable across your organization. You can also use the Public Module Registry to find pre-configured modules.

## Modularize and fix up our code

Estimated Duration: 25-30 minutes

- Task 1: Refactor your code into a module
- Task 2: Check out the Public Module Registry
- Task 3: Test, connect, validate, and cleanup

### Task 1: Refactor your existing code into a local module

Refactoring our code just means to rewrite it a new way.  Terraform allows us to use modules to separate our code and further abstract our code.  A Terraform module is just a set of configuration; refactor the existing configuration so that the webserver config is inside a module.

Create a new directory called `elb` in your directory and create a new file inside of it called `elb.tf`.

Edit the file `elb/elb.tf`, with the following variables:

```hcl
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
```

This will expose the necessary variables to our new module.  Next, add the following **resources** to the same `elb.tf` file:
- AWS Security Group Instance
- AWS Launch Config Example
- AWS Autoscaling Group Example
- AWS ELB Example
- AWS Security Group ELB

```hcl
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
    prototocol    = "tcp"
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
```

In your root configuration (also called your root module) `main.tf` file, we can remove the previous references to your configuration, since we are refactoring them as a module.  Remove all the resources **above** from your `main.tf` file.

After removing everything that we added above, add the following to our `main.tf` file to call our new elb module:
```hcl
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
```

Notice in the code block above that we need to pass the variables that we want to use to our module.

Finally, we can configure our output parameters.  We need to add an output block to your `elb.tf` file, to provide an output if called:
```hcl
output "clb_dns_name" {
  value                 = aws_elb.example.dns_name
  description           = "The domain name of the load balancer"
}
```

Our outputs need to be called from the root module. At the bottom of your `main.tf` configuration, remove  the public IP and public DNS outputs and add the following. Notice the difference in interpolation now that the information is being delivered by a module.

```hcl
output "clb_dns_name" {
  value                 = module.elb.example.dns_name
  description           = "The domain name of the load balancer"
}
```

Now run `terraform init` to install the module. Since we're just adding a module and no providers, we could optionally run `terraform get` instead, but `init` is safe to use as well. Even local modules need to be installed before they can be used.

Once that is complete, you can run `terraform plan` to validate things are working as expect3ed.

### Task 2: Explore the Public Module Registry

The creators of Terraform, HashiCorp, hosts a public module registry at: https://registry.terraform.io/

The registry contains a large set of community-contributed modules that you can use in your own configurations. Explore the registry to see what is available to you.

Search for "dynamic-keys" in the public registry and uncheck the "Verified" checkbox. You should then see a module called "dynamic-keys" created by one of HashiCorp's founders, Mitchell Hashimoto. Alternatively, you can navigate directly to https://registry.terraform.io/modules/mitchellh/dynamic-keys/aws/2.0.0.

This is the dynamic-keys module we called before!

Select this module and read the content on the Readme, Inputs, Outputs, and Resources tabs. This module will generate a public and private key pair so you can SSH into your instance.

### Task 3: Deploy, connect, and validate

Now that we have updated `main.cf` and `elb.tf` files, we can deploy our new infrastructure with these new settings.

Run `terraform init` to make sure that all modules are downloaded and available, then `terraform plan` and `terraform apply` again to build your infrastructure with the new configuration files.  Don't forget clean up afterwards...

```shell
terraform init
terraform plan
terraform apply --auto-approve
```

Once our machines have deployed, we can use our newly created key to SSH in as the ec2-user:

`$ ssh -i keys/mykeypair.pem ec2user@$(terraform output -json public_ip | jq -r '.[0])`

### Task 4: Cleanup - Use terraform to remove your machines

Remember to clean up after yourself!  Anything left running may cost you money!

Run the `terraform destroy --auto-approve` command to delete the resources you created.  We can add the `--auto-approve` option here, to prevent terraform from prompting us to continue.

```text
aws_instance.web_server: Destroying... [id=i-08aabe955824ce806]
aws_instance.web_server: Still destroying... [id=i-08aabe955824ce806, 10s elapsed]
aws_instance.web_server: Destruction complete after 41s

Destroy complete! Resources: 10 destroyed.
```

Validate within the AWS GUI console that your instance has been destroyed.

**It is important to destroy any unused running instances and such in AWS, otherwise you can be charged!!!**

When you are ready, proceed to Directory [6 - Six Friendly Felines](../6-six-friendly-felines)!