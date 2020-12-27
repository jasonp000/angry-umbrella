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

### Step 5.1.4

Now run `terraform get` or `terraform init` to install the module. Since we're
just adding a module and no providers, `get` is sufficient, but `init` is safe
to use too. Even local modules need to be installed before they can be used.

Once you've done that, you can run `terraform apply` again. Notice that the the
instance will be recreated, and its id changed, but everything else should
remain the same.

```shell
terraform apply
```

```text

# aws_instance.web will be destroyed
- resource "aws_instance" "web" {

...

# module.server.aws_instance.web will be created
+ resource "aws_instance" "web" {

...
```

## Task 2: Explore the Public Module Registry

### Step 5.2.1

HashiCorp hosts a public module registry at: https://registry.terraform.io/

The registry contains a large set of community-contributed modules that you can
use in your own configurations. Explore the registry to see what is available to
you.

### Step 5.2.2

Search for "dynamic-keys" in the public registry and uncheck the "Verified" checkbox. You should then see a module called "dynamic-keys" created by one of HashiCorp's founders, Mitchell Hashimoto. Alternatively, you can navigate directly to https://registry.terraform.io/modules/mitchellh/dynamic-keys/aws/2.0.0.

Select this module and read the content on the Readme, Inputs, Outputs, and Resources tabs. This module will generate a public and private key pair so you can SSH into your instance.

### Step 5.2.3

To integrate this module into your configuration, add this after your provider
block in `main.tf`:

```hcl
module "keypair" {
  source  = "mitchellh/dynamic-keys/aws"
  version = "2.0.0"
  path    = "${path.root}/keys"
  name    = "${var.identity}-key"
}
```

**__This module exposes the private key information in the Terraform state and should not be used in production!__**

Now you're referring to the module, but Terraform will need to download the
module source before using it. Run the command `terraform init` to download it.

To provision the resources defined by the module, run `terraform apply`, and
answer `yes` to the confirmation prompt.


### Step 5.2.4

Now we'll use the _keypair_ module to install a public key on our server. In `main.tf`, add the necessary output from our key module to our server module:

```hcl
module "server" {
  source = "./server"

  ami                    = var.ami
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  identity               = var.identity
  key_name               = module.keypair.key_name
  private_key            = module.keypair.private_key_pem
}
```

### Step 5.2.5

In your `server/server.tf` file, add two new variables to the rest of the variables at the top of the file:

```hcl
variable key_name {}
variable private_key {}
```

Add the _key_name_ variable to the _aws_instance_ resource block in
`server/server.tf`:

```hcl
resource "aws_instance" "web" {
  ami                    = var.ami
  instance_type          = "t2.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  key_name               = var.key_name

  # ... leave the rest of the block unchanged
}
```

We'll use the private_key variable later.


## Task 3: Refresh and rerun your Terraform configuration

### Step 5.3.1

Rerun `terraform apply` to delete the original instance and recreate it once
again. Now the public key will be installed on the new instance.

It may take a few minutes for the old instance to be destroyed and the new one crated. You might notice that both of these things happen in parallel:

```
...

aws_instance.web: Destroying... [id=i-00b20b227c41eca94]
module.server.aws_instance.web: Creating...
aws_instance.web: Still destroying... [id=i-00b20b227c41eca94, 10s elapsed]
module.server.aws_instance.web: Still creating... [10s elapsed]

...
```

Since there are no dependencies between the two, terraform can do both operations at the same time. This does mean that while the apply is still being run, both instances could exist at the same time, or neither might.

You'll also see that the outputs now include a list of (for now) one
_public_dns_ value and one _public_ip_:

```text
...

Apply complete! Resources: 1 added, 0 changed, 1 destroyed.

Outputs:

public_dns = ec2-54-184-51-90.us-west-2.compute.amazonaws.com
public_ip = 54.184.51.90
```

When we moved the output configuration to the _server_ module, we changed the
definition of these outputs to be lists. This is so that we can update the
module to create several instances at once in a future lab.










### Task 2: Variablize

### Task 3: Modularize

### Task 4: Modernize

### Task 5: Test, connect, validate, and cleanup

When you are ready, proceed to Directory [6 - Six F F](../6-six-f-f)!
