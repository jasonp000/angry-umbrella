# Zero - A place to start.

Hello!  This will be a starting guide.  I will walk through the steps needed to complete the next item in the sequence.  If you follow along, you too can create these things.

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

#### Task 2: Download the Remote-SSH Extension

1. Install an OpenSSH compatible SSH client if one is not already present.
    - For Windows 10, follow [these instructions from Microsoft](https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse).
      Note: If you want to use PuTTY on Windows, you mush have it in your `PATH` as `ssh.exe`
    - For MacOS and Linux, OpenSSH should already be installed. Open a terminal window and run `ssh -V` to make sure.

1. Install the [Remote Development extension pack](https://aka.ms/vscode-remote/download/extension) for VSCode.
    - In VSCode navigate to Extensions, and search for `Remote - SSH` and `Remote - SSH: Editing Configuration Files`

1. Optionally, reccomended, install the additional extensions in VSCode:
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

Make sure that you can run the `terraform` command from your remote machine, or download if necessary.  You can also download the `packer` command for future labs.  Git is also a useful tool for us.

## Create a basic AWS Instance

Estimated Duration: 25 minutes

After getting the above set up, you can create a basic instance in AWS!

### Create your first AWS deployment

You should already have some stuff ready for this






This is a work in progress, as is most things in life.

Thanks.