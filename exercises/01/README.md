# Exercise #1: Your First Terraform Project

Take a look at this directory.  You should see a couple of files aside from this README.

```bash
ls -lah
```

You'll see two .tf files:

### main.tf

Though the name of a terraform config file is mostly arbitrary, this is generally the name ascribed
to the major configuration file within a Terraform working directory.

Inside, you will see the following:

```HCL
# Declare the provider being used, in this case it's AWS.
# This provider supports setting the provider version, AWS credentials as well as the region.
# It can also pull credentials and the region to use from environment variables, which we have set, so we'll use those
provider "aws" {
  version = "~> 2.0"
}

# declare a resource stanza so we can create something, in this case a key pair
resource "aws_key_pair" "my_key_pair" {
  key_name   = "rockholla-di-${var.student_alias}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 ${var.student_alias}+di@rockholla.org"
}
```

### variables.tf

Now look into the "variables.tf" file.  You should see this:

```hcl
# Declare a variable so we can use it
variable "student_alias" {
  description = "Your student alias"
}
```

This directory is a very simple example of a terraform project or module.

### Commands

So we have these files that make up our project, now what?  Well, let's try to run some terraform commands against them

```bash
# init is generally the first command you run after writing your config files.  It does
# a few things but a simple way to thing about init: it initializes the working directory to prepare
# it to run plans and applies
terraform init

# FMT is a very simple syntax corrector that analyzes HCL in a given directory
# (including sub-directories) and corrects small syntactical issues.
terraform fmt

# "validate" runs a deeper scan of config to show potential issues with more complex
# problems like circular dependencies and missing values. v0.12 made validate a bit simpler
# as far as the tasks it performs
terraform validate
```

If your "terraform init" command was successful, then you should be ready to move on. For now, don't run an apply.  
We will get to this in a future exercise.
