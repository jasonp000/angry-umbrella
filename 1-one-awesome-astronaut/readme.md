# #1 - One Awesome Astronaut Andy - Deploy and manipulate an instance in AWS.

Ok!  You should have a basic working environment, where you will be able to manipulate files and execute terraform commands.  Next steps, let's create some infrastructure!

## Part One - Create a basic AWS instance

Estimated Duration: 20-25 minutes

After getting the environment set up, you can create a basic instance in AWS!

### Create your first AWS deployment

We will use Terraform to deploy a new instance to AWS.  There are a few tasks we want to complete, to make sure we maintain a consistent working environment for creating our infrastructure.

- Task 1: Create a new working directory and initial config
- Task 2: Deploy an instance with Terraform
- Task 3: Get machine info & validate
- Task 4: Update config and apply

#### Task 1: Create a working directory and initial configuration file

Create a new directory for your first files.  You can call this anything you want.  I will use the name `~/new_working_dir` in my examples...

Create a file in your new directory named `main.tf` - this will be our first Terraform configuraion file.  We want our file to contain the following items to be configured:
- `ami` - The actual Amazon Machine Image to build our instance from
- `instance_type` - The type/size/specs of the instance to build
- `tags.Name` - A simple tag for the Name parameter

Your `main.tf` file should look similar to this (with potentially different values):
```hcl
resource "aws_instance" "web" {
  ami                    = "ami-04d29b6f966df1537"
  instance_type          = "t2.micro"

  tags = {
    "Name" = "My Instance Name"
  }
}
```

Don't forget to save the file before moving on!  You can configure VSCode to autosave...

#### Task 2: Use Terraform to deploy your new machine

##### Navigate to the new directory and initialize Terraform:

Initializing terraform will create the necessary configuration files in the current working directory that terraform will use to maintain information about your deployments.  Do not modify these files unless absolutely necessary!

```shell
$ cd ~/new_working_dir
$ terraform init

Initializing the backend...

Initializing provider plugins...

...

Terraform has been successfully initialized!
```

##### Plan your new configuration, and examine the output

A terraform plan is used to create an execution plan. Terraform does a refresh and determines what actions are necessary to achieve the state specified in the config files.

```shell
$ terraform plan

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

...

Plan: 1 to add, 0 to change, 0 to destroy.
```

##### Apply your new configuration

Run the `terraform apply` command to generate **real** resources in AWS

```shell
$ terraform apply

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

...

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```

You will be prompted to confirm the changes before they're applied. Respond with `yes` to confirm.

```shell
aws_instance.web_server: Creating...
aws_instance.web_server: Still creating... [10s elapsed]
aws_instance.web_server: Still creating... [20s elapsed]
aws_instance.web_server: Still creating... [30s elapsed]
aws_instance.web_server: Creation complete after 34s [id=i-05d2bc520b72e64da]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```
#### Task 3: Get your machine's info and validate it is up

Use the `terraform show` command to view the resources created and validate the instance is running:

```shell
$ terraform show | grep 'instance_state\|public_ip'
    associate_public_ip_address  = true
    instance_state               = "running"
    public_ip                    = "3.82.136.222"
```

If the instance_state is running, we have successfully created a new AWS instance!

Optionally ping that address to ensure the instance is up and running.  It may not respond, depending on how your default security group is created.  It may also take a few minutes for the machine to respond after being built...

```shell
$ ping -c4 3.82.136.222

PING 3.82.136.222 (3.82.136.222) 56(84) bytes of data.
64 bytes from 3.82.136.222: icmp_seq=1 ttl=235 time=23.2 ms
...
```

You can also verify within the AWS GUI console that your new instance is up and running.

#### Task 4: Update your machine's configuration

Terraform can perform in-place updates on your instances after changes are made to the `main.tf` configuration file.  Update your config as described below.

##### Add two tags to the AWS instance in your `main.tf` file:

- Identity
- Environment

```hcl
  tags = {
    "Name"        = "My Instance Name"
    "Identity"    = "##-2-digit-student-number"
    "Environment" = "Training"
  }
```

##### Plan and apply the changes you just made

In order to apply our new changes, we need to run `terraform apply`.  We can also run `terraform plan` to just view a report of what would be changed.

Note the output differences for additions, deletions, and in-place changes.

```shell
$ terraform apply
```

You should see output indicating that the _aws_instance.web_ will be modified:

```text
...

# aws_instance.web will be updated in-place
~ resource "aws_instance" "web" {

...

Plan: 0 to add, 1 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: 
```

When prompted to apply the changes, respond with `yes`.

```text
...

aws_instance.web_server: Modifying... [id=i-05d2bc520b72e64da]
aws_instance.web_server: Modifications complete after 2s [id=i-05d2bc520b72e64da]

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

Validate within the AWS GUI console that your changes have been applied.

At this point we have a machine, but it doesn't actually do anything.  Next we will destroy the machine, and then setup a basic web server.

### Use terraform to remove your machines

Terraform is stateful, meaning that it maintains a copy of your configuration state in your current deployment.  By default, this state is kept in your working directory - that is wherever you ran your terraform commands from.  If you are following along my examples, this would be in the directory `~/0-new_working_dir`.  Make sure you are in this directory, and run the `terraform destroy` command to remove your items.

```code
$ cd ~/0-new_working_dir
$ terraform destroy

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_instance.web_server will be destroyed
  - resource "aws_instance" "web_server" {

...

Plan: 0 to add, 0 to change, 1 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value:
```

You will be prompted to destroy the infrastructure.  Respond with `yes`.

```text
aws_instance.web_server: Destroying... [id=i-05d2bc520b72e64da]
aws_instance.web_server: Still destroying... [id=i-05d2bc520b72e64da, 10s elapsed]
aws_instance.web_server: Destruction complete after 41s

Destroy complete! Resources: 1 destroyed.
```

Validate within the AWS GUI console that your instance has been destroyed.

**It is important to destroy any unused running instances and such in AWS, otherwise you can be charged!!!**

## Part Two - Create a simple web server AWS instance

Estimated Duration: 5-10 minutes

The machine we created above doesn't actually do anything for us, so let's make something better.  With a few quick modifications, our machine will install a basic web server for us, and display the IP address as an output value for us at runtime.

### Set up our machine as a basic web server and add output data

We will use the *user_data* parameter to install and start the web server package and create a default webpage.  The *user_data* is where we can put commands to be run on our instance after startup.

We will also have terraform display the IP address of our new machine as an output value, so we don't have to look it up ourselves.

- Task 1: Add the `user_data` to your resource
- Task 2: Add an output variable to your configuration
- Task 3: Deploy the new thing and check it!
- Task 4: Destroy and cleanup

#### Task 1: Add a user_data parameter to your aws_instance resource

Add these *user_data* commands in your `main.tf` configuration file ***within*** the aws_instance resource.  These commands will be run at startup to build our basic web server:

```hcl
  user_data = <<-EOF
              #!/bin/bash
              sudo yum -y install httpd
              sudo echo "Hello World" > /var/www/html/index.html
              sudo systemctl start httpd
              EOF
```

#### Task 2: Add an output variable to your `main.cf`

The IP address of our instance is not known until the instance is built, and we don't want to have to manually look it up every time we build a machine.  Our solution is to tell terraform to output the value after building our new instance.

Add the following to the end of your `main.tf` file to create an ip address output value.

```hcl
    output "public_ip" {
      value = aws_instance.web_server.*.public_ip
      description = "Public IP Address"
    }
```

#### Task 3: Deploy and check!

Execute the `terraform plan` and `terraform apply` commands to deploy your updated instance:

```code
$ terraform plan

...

$ terraform apply

    An execution plan has been generated and is shown below.
    Resource actions are indicated with the following symbols:
      + create

    Terraform will perform the following actions:

      # aws_instance.web_server will be created
      + resource "aws_instance" "web_server" {

      ...

      aws_instance.web_server: Creating...
      aws_instance.web_server: Still creating... [10s elapsed]
      aws_instance.web_server: Still creating... [20s elapsed]
      aws_instance.web_server: Still creating... [30s elapsed]
      aws_instance.web_server: Creation complete after 34s [id=i-08aabe955824ce806]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

public_ip = [
  "34.227.171.111",
]
```

Notice in the output above, you have the public IP address for your new server!

After applying, you will have a new instance, running a web server, on the ip address listed.  Wait a few minutes, then open a web browser and browse to the IP address listed.

### Task 4: Cleanup

Run the `terraform destroy --auto-approve` command to delete the resources you created.  We can add the `--auto-approve` option here, to prevent terraform from prompting us to continue.

```text
aws_instance.web_server: Destroying... [id=i-08aabe955824ce806]
aws_instance.web_server: Still destroying... [id=i-08aabe955824ce806, 10s elapsed]
aws_instance.web_server: Destruction complete after 41s

Destroy complete! Resources: 1 destroyed.
```

Validate within the AWS GUI console that your instance has been destroyed.

**It is important to destroy any unused running instances and such in AWS, otherwise you can be charged!!!**

Congratulations, you can now move to Directory [2 - Two Big Brains](../2-two-big-brains)!
