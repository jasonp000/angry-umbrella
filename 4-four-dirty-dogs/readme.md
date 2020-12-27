# #4 - Four Dirty Dishes David - Variablize and clean up our code

We should clean up what we have, and update our stuff a bit.  What we have doen so far is fairly limited, and can be greatly expanded by using variables and modules and some additional settings.

## Modernize and fix up our code

Estimated Duration: 15-20 minutes

- Task 1: Variablize
- Task 2: Remove old rubbish
- Task 3: Deploy, connect, and validate
- Task 4: Cleanup

### Task 1: Variablize

First, add the following variable blocks to the top of our `main.tf` file:
```hcl
variable "access_key" {}
variable "secret_key" {}
variable "aws_session_token" {}
variable "region" {
  default = "us-east-1"
}
```
Adding this will allow us to expose these variables for use in our code.

**Note: If you do not have an aws_session_token, you can omit that variable.  The token is needed with AWS Educate**

Next, update your aws provider block to use these new variables:
```hcl
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  token      = var.aws_session_token
  region     = var.region
}
```
This is called **interpolation** - we replace the hard coded values with the variable representation for these values.

Now, run the `terraform plan` command, and notice that it is now asking you for values for the variables:
```
& terraform plan
```
```
var.access_key
  Enter a value:
```
Press crtl+c to cancel.

Since we did not provide any default or configured value for the access key and secret key, Terraform will prompt us to enter those values at runtime.  We don't want to put the values for these variables in our terraform script, so instead we will create a new variable file to use.  Create a new file called `terraform.tfvars` and add the following:
```hcl
access_key             = "<ACCESS_KEY>"
secret_key             = "<SECRET_KEY>"
aws_session_token      = "<SESSION_TOKEN>"
subnet_id              = "<SUBNET_ID>"
identity               = "<STUDENT_IDENTITY>"
vpc_security_group_ids = ["<SECURITY_GROUP_ID>"]
ami                    = "ami-04d29b6f966df1537"
region                 = "us-east-1"
instance_type          = "t2.micro"
server_port            = "80"
elb_port               = "80"
ssh_port               = "22"
```

Replace any value in <brackets> with your unique values.

Next, update our `main.tf` code to use these new variables.  There are a lot of variables that can be replaced; you can view the [main.tf](./main.tf) in this directory to see the finished script.  Some of the items to change include:
- Instance security group ingress ports
  ```hcl
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
  ```

- Launch config image_id and instance_type
  ```hcl
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
  ```

- ELB security group ingress port
  ```hcl
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

### Task 2: Remove old rubbish

Continuing on with our variable changes, let's clean up a bit.  Since we put our `server_port` and `elb_port` variables into our `terraform.tfvars` variable file, we need to remove the definitions we already had.

***REMOVE*** the following `server_port` and `elb_port` variable definition blocks from your `main.tf` file:
```hcl
variable "server_port" {
  description   = "The port the server will use for HTTP requests"
  type          = number
  default       = 80
}
variable "elb_port" {
  description   = "The port the ELB will use for HTTP requests"
  type          = number
  default       = 80
}
```

At this point, you can run a `terraform plan` to check your code changes and validate things are working as expected.

### Task 3: Deploy, connect, and validate

Now that we have an updated main.cf file, we can deploy our new infrastructure with these new settings:

```shell
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

Destroy complete! Resources: 1 destroyed.
```

Validate within the AWS GUI console that your instance has been destroyed.

**It is important to destroy any unused running instances and such in AWS, otherwise you can be charged!!!**

When you are ready, proceed to Directory [5 - Five Eerie Extraterrestrials](../5-five-eerie-extraterrestrials)!
