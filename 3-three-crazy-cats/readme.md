# #3 - Three Crazy Cats Caryn - Even More Complicated Server Setup - ASG, ELB, Launch Config

A single web server providing services to your customers *works* but is not great.  Realistically you want multiple web servers, with a load balancer sitting in front of them.  To do this, lets create a Classic Elastic Load Balancer.  In conjunction with the ELB is the Auto Scaling Group, which will allow us to scale servers on demand.  Finally, along with the ASG is the Launch Config, which specifies how machines are created and launched by the ASG.

## Create a basic security group definition, add SSH keys, and add some variables

Estimated Duration: 15-20 minutes

- Task 1: Add the Elastic Load Balancer variables, definition, and security group
- Task 2: Add a Launch Configuration definition and remove the instance def
- Task 3: Create an autoscaling group definition
- Task 4: Plan and apply
- Task 5: Connect and validate
- Task 6: Cleanup

### Task 1: Add the ELB variables, definition, and security group

First, add the following to your `main.tf` near the top to create a variable for the ELB port:
```hcl
variable "elb_port" {
  description   = "The port the ELB will use for HTTP requests"
  type          = number
  default       = 80
}
```

Next, we want to create a new security group for our ELB.  We could use the same security group as we used for our instance, but best practice is to create a new one!  Add the following code to create a new security group named `elb`.
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
    from_port           = 80
    to_port             = 80
    protocol            = "tcp"
    cidr_blocks         = ["0.0.0.0/0"]
  }
}
```

Now we can create the actual Classic Elastic Load Balancer with the following code:
```hcl
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
```

### Task 2: Add a Launch Configuration resource and remove the instance definition
Next, we want to change our instance resource to use a Launch Configuration resource instead.  Remove your web_server aws_instance resource, and replace it with the below example aws_launch_configuration code instead:
```hcl
resource "aws_launch_configuration" "example" {
  image_id        = "ami-04d29b6f966df1537"
  instance_type   = "t2.micro"
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
This provides the same kind of functionality, but adds a new option for us - create_before_destroy.  This forces terraform to replace any created instances with new ones before destroying the old.

### Task 3: Create an autoscaling group definition

The last piece we need is an autoscaling group.  This is what actually defines how many instances we want running, and allows us to set rules around adding or removing nodes from the group.
```hcl
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
```
### Task 4: Deploy, connect and validate

Now that we have an updated main.cf file, we can deploy our new infrastructure with these new settings:

```shell
terraform init
terraform plan
terraform apply --auto-approve
```

### Task 5: Connect and validate

Once our machines have deployed, we can use our newly created key to SSH in as the ec2-user:

`$ ssh -i keys/mykeypair.pem ec2user@$(terraform output -json public_ip | jq -r '.[0])`

### Task 6: Cleanup - Use terraform to remove your machines

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

When you are ready, proceed to Directory [4 - Four Dirty Dishes](../4-four-dirty-dishes)!
