# #2 - Two Big Brains Brad - Add some variables and modules and more

Now that we have been able to create a basic web server, let us variablize our configuration, implement a security group firewall around our instance, and dynamically create SSH keys for use with our new instance.

## Create a basic security group definition, add SSH keys, and add some variables

Estimated Duration: 15-20 minutes

- Task 1: Add some variables
- Task 2: Add the SSH module
- Task 3: Create a security group definition
- Task 4: Connect and validate

### Task 1: Add a variable for our web server port

Instead of hard coding the value we want to use, lets use a variable instead.  Add the following to the beginning of the `main.tf` configuration file from our previous exercise:

```hcl
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 80
}
```
This will define the `server_port` variable for us, which we will use later...  We could optionally add additional variables if we desired.

### Task 2: Add the SSH module to our code

If we want to securely log in to our instance, we will need an SSH keypair to do so.  Amazon does not allow the use of passwords to log in by default.  We can use the terraform SSH module.

Add the below SSH module code to your main.tf file, below the variable statement you just added:

```hcl
module "keypair" {
  source  = "mitchellh/dynamic-keys/aws"
  version = "2.0.0"
  path    = "${path.root}/keys"
  name    = "mykeypair-key"
}
```

In order to use this module with our instance, we need to define the module within our instance.  Add the following ***within*** your aws_instance resource, below the instance_type definition:

```hcl
key_name               = module.keypair.key_name
```

### Task 3: Create a new security group definition for our instance

Our last instance was created with the default security group.  This default security group does not offer the control that we want, so we will create our own security group with the settings we desire.  We will allow port 22, and use the variable interpolation syntax to create the appropriate open web server port.

Add the following resource block to your `main.tf` file, after the keypair module you just added above.

```hcl
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
```

This security group resource will allow inbound traffic from any source on port 22, and also on the port defined in our earlier `server_port` variable definition.  The definition will also allow all outbound traffic to all destinations.

In order to use this security group resource with our instance, we need to define the resource within our instance.  Add the following ***within*** your aws_instance resource, below the key_name definition:

```hcl
vpc_security_group_ids = [aws_security_group.instance.id]
```

### Task 4: Deploy, connect and validate

Now that we have an updated main.cf file, we can deploy a new instances with these updated settings:

```shell
terraform init
terraform plan
terraform apply --auto-approve
```

Once our machine has deployed, we can use our newly created key to SSH in as the ec2-user:
`ssh -i keys/mykeypair.pem ec2user@$(terraform output -json public_ip | jq -r '.[0])`

Alrighty then, lets move on to Directory [3 - Three Crazy Cats](../3-three-crazy-cats)!
