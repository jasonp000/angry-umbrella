# #4 - Four Dirty Dishes David - Cleanup and variablize and modularize and modernize

We should clean up what we have, and update our stuff a bit.  What we have doen so far is fairly limited, and can be greatly expanded by using variables and modules and some additional settings.

## Cleanup

Estimated Duration: 25-30 minutes

- Task 1: Variablize
- Task 2: Cleanup
- Task 3: Modularize
- Task 4: Modernize
- Task 5: Test, connect, validate, and cleanup

### Task 1: Variablize

Add the following variable blocks to the top of our file:
```hcl
variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "us-east-1"
}
variable "ami" {}
variable "subnet_id" {}
variable "identity" {}
variable "vpc_security_group_ids" {
  type = list
}
```

Update your aws provider block to use these new variables:
```hcl
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}
```

Run the `terraform plan` command, and notice that it is now asking you for values for the variables:
```
& terraform plan
```
```
var.access_key
  Enter a value:
```
Press crtl+c to cancel.

Since we did not provide any default or configured value for the access key and secret key, Terraform will prompt us to enter those values at runtime.  We don't want to put the values for these variables in our terraform script, so instead we will create a new variables file to use.  Create a new file called `terraform.tfvars` and add the following:
```hcl
access_key             = "<ACCESS_KEY>"
secret_key             = "<SECRET_KEY>"
subnet_id              = "<SUBNET_ID>"
identity               = "<STUDENT_IDENTITY>"
region                 = "<REGION>"
vpc_security_group_ids = ["<SECURITY_GROUP_ID>"]
num_webs               = "1"
ami                    = "<AMI_ID>"
```

Next, edit the resource block to use these new variables:


### Task 2: Cleanup

### Task 3: Modularize

### Task 4: Modernize

### Task 5: Test, connect, validate, and cleanup

When you are ready, proceed to Directory [5 - Five Eerie Extraterrestrials](../5-five-eerie-extraterrestrials)!
