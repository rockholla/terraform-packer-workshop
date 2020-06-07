# Exercise #3: Plans and Applies

So now we are actually going to get into it and make some infrastructure happen.  For this exercise, we are going to:

1. Initialize our project directory that is this exercise directory
1. Run a plan to understand why planning makes sense, and should always be a part of your terraform workflow
1. Actually apply our infrastructure, in this case a creating an AWS EC2 key pair, or ssh key for connecting to instances
1. Destroy what we created

### Initialization

First, we need to run init since we're starting in a new exercise, or project directory:

```bash
terraform init
```

### Plan

Next step is to run a plan, which is a dry run that helps us understand what terraform intends to change when it
runs an apply.  

Remember from the previous exercise that we'll need to make sure our `student_alias` value gets passed in appropriately.
Pick whichever method of doing so, and then run your plan:

```bash
terraform plan
```

Your output should look something like this:

```
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_key_pair.my_key_pair will be created
  + resource "aws_key_pair" "my_key_pair" {
      + fingerprint = (known after apply)
      + id          = (known after apply)
      + key_name    = "rockholla-di-force"
      + key_pair_id = (known after apply)
      + public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 force+di@rockholla.org"
    }

Plan: 1 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

From the above output, we can see that terraform will create a key pair.  An important line
to note is the one beginning with "Plan:".  We see that 1 resource will be created, 0 will be changed, and 0 destroyed.  
Terraform is designed to detect when there is configuration drift in resources that it created and then intelligently
determine how to correct the difference. This will be covered in more detail a little later.

### Apply

Let's go ahead and let Terraform create the key pair. Maybe try a different method of passing in your `student_alias`
variable when running the apply:

```bash
terraform apply
```

Terraform will execute another plan, and then ask you if you would like to apply the changes. Type "yes" to approve, then
let it do its magic.  Your output should look like the following:

```
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_key_pair.my_key_pair will be created
  + resource "aws_key_pair" "my_key_pair" {
      + fingerprint = (known after apply)
      + id          = (known after apply)
      + key_name    = "rockholla-di-force"
      + key_pair_id = (known after apply)
      + public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 force+di@rockholla.org"
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_key_pair.my_key_pair: Creating...
aws_key_pair.my_key_pair: Creation complete after 1s [id=rockholla-di-force]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

Now lets run a plan again.

```bash
terraform plan
```

You should notice a couple differences:

* Terraform informs you that it is Refreshing the State.
    * after the first apply, any subsequent plans and applies will check the infrastructure it created and updates the terraform state with any new information about the resource.
* Next, you'll notice that Terraform informed you that there are no changes to be made.  This is because the infrastructure was just created and there were no changes detected, no changes to your instructure code instructions.

### Handling Changes

Now, lets try making a change to the key pair and allow Terraform to correct it.  Let's change the content of our public key.

Find `main.tf` and modify the key pair resource definition:

```hcl
# declare a resource stanza so we can create something, in this case a key pair
resource "aws_key_pair" "my_key_pair" {
  key_name   = "rockholla-di-${var.student_alias}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 ${var.student_alias}+di-alt@rockholla.org"
}
```

Just changing the public key email from `${var.student_alias}+di@rockholla.org` to `${var.student_alias}+di-alt@rockholla.org`

Now run another apply:

```bash
terraform apply
```

The important output for the plan portion of the apply that you should note, something that looks like:

```
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # aws_key_pair.my_key_pair must be replaced
-/+ resource "aws_key_pair" "my_key_pair" {
      ~ fingerprint = "d7:ff:a6:63:18:64:9c:57:a1:ee:ca:a4:ad:c2:81:62" -> (known after apply)
      ~ id          = "rockholla-di-force" -> (known after apply)
        key_name    = "rockholla-di-force"
      ~ key_pair_id = "key-0d1d79becf8b9e4d6" -> (known after apply)
      ~ public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 force+di@rockholla.org" -> "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 force+di-alt@rockholla.org" # forces replacement
      - tags        = {} -> null
    }

Plan: 1 to add, 0 to change, 1 to destroy.
```

A terraform plan informs you with a few symbols to tell you what will happen

* `+` means that terraform plans to add this resource
* `-` means that terraform plans to remove this resource
* `-/+` means that terraform plans to destroy then recreate the resource
* `+/-` is similar to the above, but in certain cases a new resource needs to be created before destroying the previous one, we'll cover how you instruct terraform to do this a bit later
* `~` means that terraform plans to modify this resource in place (doesn't require destroy then re-create)
* `<=` means that terraform will read the resource

So our above plan will "modify" our key pair by deleting the previous one and creating a new one in its place.

Some resources or some changes require that a resource be recreated to facilitate that change, and those cases are usually expected.
One example of this would be an AWS launch configuration, or our key pair type resource as we saw above. In AWS, launch configurations and key pairs are 2 examples of resources that are immutable, cannot be changed.  Terraform is generally made aware of these caveats and handles those changes gracefully, including updating dependent resources to link to the newly created resource.  This greatly simplifies complex or frequent changes to any size infrastructure and reduces the possibility of human error.

### Destroy

When infrastructure is retired, Terraform can destroy that infrastructure gracefully, ensuring that all resources
are removed and in the order that their dependencies require.  Let's destroy our key pair.

```bash
terraform destroy
```

You should get the following:

```
aws_key_pair.my_key_pair: Refreshing state... [id=rockholla-di-force]

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_key_pair.my_key_pair will be destroyed
  - resource "aws_key_pair" "my_key_pair" {
      - fingerprint = "d7:ff:a6:63:18:64:9c:57:a1:ee:ca:a4:ad:c2:81:62" -> null
      - id          = "rockholla-di-force" -> null
      - key_name    = "rockholla-di-force" -> null
      - key_pair_id = "key-0841c586653291ada" -> null
      - public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 force+di-alt@rockholla.org" -> null
      - tags        = {} -> null
    }

Plan: 0 to add, 0 to change, 1 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_key_pair.my_key_pair: Destroying... [id=rockholla-di-force]
aws_key_pair.my_key_pair: Destruction complete after 1s

Destroy complete! Resources: 1 destroyed.
```

You'l notice that the destroy process if very similar to apply, just the other way around! And it also requires
confirmation, which is a good thing.
