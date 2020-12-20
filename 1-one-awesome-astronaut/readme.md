# One - A Basic Server Setup

This is a basic AWS instance deployment configuration.
The instance will be deployed with the default security group.
The instance will be built as a t2.micro machine type with an Amazon Linux 2 AMI.

First - Make sure your `~/.aws/credentials` file contains your default AWS credentials:
 * `aws_access_key_id=`
 * `aws_secret_access_key=`
 * `aws_session_token=`

Second - Download the latest version of terraform, and make sure it is in your $PATH
 * `/usr/local/bin/` is a common place

Third - Use git to clone this repo for local work and commands and such:
 * `git git@github.com:USERNAME/REPONAME.git`

Fourth - Make any changes to code as you see fit...

Fifth - Initialize, plan, and apply the terraform code!

    terraform init
    terraform plan
    terraform apply

## Work in Progress

### Thanks