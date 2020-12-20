# Zero - A place to start.

Hello!  This will be a starting guide.  I will walk through the steps needed to complete the next item in the sequence.  If you follow along, you too can create these things.

I'm stealing some stuff from heere: https://github.com/gmaentz/terraform_training/

## Set up your editor and environment

Estimated Duration: 20 minutes

You will need a few things installed and a few pieces of information to get started.  Your instructor will provide any necessary information (accounts, addresses, etc).  You'll need to be able edit files and run commands on your machine.  This section details a simple way to set up your environment, however you can always do things differently.  Follow these steps below to connect to your SSH account within VSCode.

### Visual Studio Code

Visual Studio Code, or VSCode, is a free popular open source editor from Microsoft. Using an extension called Remote-SSH, you can connect to a remote SSH account, edit files, and run commands all from within VSCode.

There are a few steps to install and configure VSCode, but once set up, this provides an easy to use environment.

- Task 1: Download VSCode
- Task 2: Download the Remote-SSH Extension
- Task 3: Configure SSH
- Task 4: Connection to your workstation in VSCode

#### Task 1: Download VSCode to your local machine and configure extensions

1. Follow the instructions from [this site](https://code.visualstudio.com/download) to get the latest official download for your operating system.

1. Get familiar with the VSCode user interface. Many things we do are supported natively with VSCode, and we will add extensions to provide extra functionality.

#### Task 2: Download the Remote-SSH and additional extensions

1. Install an OpenSSH compatible SSH client if one is not already present.
    - For Windows 10, follow [these instructions from Microsoft](https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse).
      Note: If you want to use PuTTY on Windows, you mush have it in your `PATH` as `ssh.exe`
    - For MacOS and Linux, OpenSSH should already be installed. Open a terminal window and run `ssh -V` to make sure.

1. Install the [Remote Development extension pack](https://aka.ms/vscode-remote/download/extension) for VSCode.
    - In VSCode navigate to Extensions, and search for `Remote - SSH` and `Remote - SSH: Editing Configuration Files`

1. Optionally (reccomended) install these additional extensions in VSCode:
    - GitHub Pull Requests and Issues
    - HashiCorp Terraform
    - Python

#### Task 3: Configure SSH

1. Set up your SSH keys

    VSCode will need to make multiple SSH connections to your workstation. This can mean that it will ask for your password for each connection. To avoid this, you can create SSH keys.

    First: On your local machine run the command `ssh-keygen`
      * This will create the necessary directories along with a local public/private key pair for SSH connections.
    
    Second: On the remote run the command `ssh-keygen`
      * This will create the necessary directories along with a remote public/private key pair for SSH connections.

    Third: Add the public key from the local machine to the authorized_keys file of the remote machine:
      * Manually copy the contents of `~/.ssh/id_rsa.pub` on the local host to `~/.ssh/authorized_keys` on the remote host.
      * Optionally run `ssh-copy-id` from the local machine to copy the public key to the remote machine.
      * An example of a public key in an authorized_keys file is below:

    ```text
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBV37j8V2XBLbWdL8/E7JBLAHBLAHBLAH0ZRVJORXxsnEszMDgolOtspfT/JTWeWsEtkarJQfYiBXMAfeEcJzEQ9CiRGLdwIh5CWPWjrfXOicK4sohKNvvqg3Hg6z9uzp3tzKNz6GqYlQeYZ6LS/rnZyZkvSR0= user@computer   
    ```

1. Create your local ssh config on your machine.

Create an ssh config file in `~/.ssh/` called `config` and add your workstation and user information.  For example:

    ```text
    Host nickname
        User username
        HostName fqdn_or_ip
    ```

This information will be provided for you by the instructor.

#### Task 4: Connect to your server in VSCode

1. Using the Command Palette, choose `Remote-SSH: Connect to Host...`
1. Select your SSH config file
    - For Windows, this is `c:\Program Files\Git\etc\ssh\config` ???
    - For Mac or Linux, the file is `~/.ssh/config`
1. Open the explorer in VSCode and choose `Open Folder`
1. Navigate to `~`
1. You can also launch a terminal from VSCode for remote command line execution.  I am a big fan of this.

### SSH

If you'd prefer to SSH directly into the server (instead of, or in addition to, VSCode), you can do that as well.  You should already be familiar with how to use SSH and editing from the CLI.  On Windows, use an SSH client such as PuTTY or OpenSSH. On a Linux or Mac, use the Terminal and OpenSSH to connect to your workstation.  Those details are out of scope for this documentaiton.

### Get Terraform, packer, and any other server side software needed

Make sure that you can run the `terraform` command from your remote machine, or download it if necessary.  You can also download the `packer` command for future labs.  Git is also a useful tool for us, so you should install that as well.  Validate that the commands are working, by running the below commands in a terminal:

```shell
terraform -version
```

You should see:

```text
Terraform v0.14.3
```

## Create a basic AWS Instance

Estimated Duration: 25 minutes

After getting the above set up, you can create a basic instance in AWS!

### Create your first AWS deployment

Create a new directory for your first files.  You can call this anything you want.  I will use the name `0-new_working_dir` in my examples...

Create a file in your new directory named `main.tf` - this will be our first Terraform configuraion file.  We will want our file to contain the following items configured:

- ami - The actual Amazon Machine Image to build our instance from
- instance_type - The type/size/specs of the instance to build
- tags.Name - A simple tag for the Name parameter

Your final `main.tf` file should look similar to this (with different values):

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

### Use Terraform to deploy your new machine

#### Navigate to the new directory and initialize Terraform:
```shell
cd ~/0-new_working_dir
terraform init
```

```text
Initializing provider plugins...
...

Terraform has been successfully initialized!
```

#### Plan your new configuration, and examine the results
```shell
terraform plan
...
...
...
```

#### Apply your new configuration

Run the `terraform apply` command to generate real resources in AWS

```shell
terraform apply
...
...
...
```

You will be prompted to confirm the changes before they're applied. Respond with
`yes` to confirm.

#### Get your machine's info

Use the `terraform show` command to view the resources created and find the IP address for your instance.

Ping that address to ensure the instance is running and responding.

#### Update your machine's configuration

Terraform can perform in-place updates on your instances after changes are made to the `main.tf` configuration file.

Add two tags to the AWS instance in your `main.tf` file:

- Identity
- Environment

```hcl
  tags = {
    "Identity"    = "##2-digit-number"
    "Name"        = "My Instance Name"
    "Environment" = "Training"
  }
```

#### Plan and apply the changes you just made

Note the output differences for additions, deletions, and in-place changes.

```shell
terraform apply
```

You should see output indicating that the _aws_instance.web_ will be modified:

```text
...

# aws_instance.web will be updated in-place
~ resource "aws_instance" "web" {

...
```

When prompted to apply the changes, respond with `yes`.

### Use terraform to remove your machines

Terraform is stateful, meaning that it maintains a copy of your configuration state in your current deployment.  By default, this state is kept in your working directory - that is whereever you ran your terraform commands from.  If you are following along my examples, this would be in the directory `~/0-new_working_dir`.  Make sure you are in this directory, and run the `terraform destroy` command to remove your items.

```codd
~/0-new_working_dir
terraform destroy
```

You will be prompted to destroy the infrastructure.  Respond with `yes`.
It is important to destroy any unused running instances and such in AWS, otherwise you can be charged!

###### This is a work in progress, as is most things in life.

Thanks.