# Exercise #12: First Packer Project

A Packer project, at it's simplest can be a single template with a single build. So, that's where we'll start...with a first look at variables as well.

And we'll do so by building an AWS AMI using the builder type `amazon-ebs`. As you go through this exercise, feel free to reference [the available documentation for this builder](https://www.packer.io/docs/builders/amazon-ebs.html).

## How authentication works

Every type of builder will ultimately handle authentication to the build environment, where applicable, slightly differently. In the case of our exercise here, we're making sure that the standard AWS CLI/API environment variables get passed through to the builder.

*NOTE: the builder itself could just read directly from the environment variables without this template-level variable flow. But, for the sake of the exercise, it's worth looking at a more explicit authentication flow.*

So, for our exercise, we use the environment variables we set in our Cloud9 environment back on day 1. Packer is able to pass those through to the builder to authenticate.

Authentication allows Packer to talk to the AWS API to create the builder EC2 instance, configure necessary items in our AWS EC2 area for connecting, making the connection, and finally creating the resulting AMI.

To see this more clearly, we'll go ahead and switch over to looking at the template we'll use...

## Let's look at `template.json`

We want to review our template file first before we run anything. We'll use what we've learned so far to make some sense of it.

```json
{
  "variables": {
    "aws_access_key": "{{env `AWS_ACCESS_KEY_ID`}}",
    "aws_secret_key": "{{env `AWS_SECRET_ACCESS_KEY`}}",
    "username": null
  },
  "builders": [
    {
      "name": "{{ user `username` }}-first-ami",
      "type": "amazon-ebs",
      "access_key": "{{user `aws_access_key`}}",
      "secret_key": "{{user `aws_secret_key`}}",
      "region": "us-west-1",
      "source_ami": "ami-0dd655843c87b6930",
      "instance_type": "t2.micro",
      "ssh_username": "ubuntu",
      "ami_name": "{{ user `username` }}-first-ami"
    }
  ]
}
```

If we step through the parts of this template, we'll get a better understanding of what we're working with in this particular example. First, a look at the root `variables` section:

```json
"variables": {
  "aws_access_key": "{{env `AWS_ACCESS_KEY_ID`}}",
  "aws_secret_key": "{{env `AWS_SECRET_ACCESS_KEY`}}",
  "username": null
},
```

This block defines user, or input, variables to our template and utimately their use in the defined `builders`. Our first two variables here are, of course, about how Packer will authenticate. In this case, we're making use of built-in Packer template engine capabilities of using environment variables on the machine running the Packer CLI. We'll cover the template engine and more on this type of syntax and other available template engine capabilities later in the day.

The last variable, `username`, has one very important part of it's definition: the fact this it's set to `null`. A default value of `null` makes this variable required, and you must pass a value for it at build time. So, let's try to run our build without it just to see what happens:

```bash
$ packer build ./template.json
Error initializing core: 1 error occurred:
	* required variable not set: username



==> Builds finished but no artifacts were created.

```

The built-in Packer validation has trapped the fact that we've not passed in a value for `username`. It's required per our template definition, so all we need to do is pass in a value for it. Pass the username/alias that was provided to you for exercises:

```bash
$ packer build -var username=[provided username/alias] ./template.json
force-first-ami: output will be in this color.

==> [provided username/alias]-first-ami: Prevalidating any provided VPC information
...
```

The build should now proceed as normal, and your first AMI is in the making.

*NOTE: if you receive any authentication-related errors, you likely don't have the environment variables `AWS_ACCESS_KEY_ID` and/or `AWS_SECRET_ACCESS_KEY` set, thus they haven't been provided to Packer appropriately via the template logic*

While we're waiting for our AMI builds to actually complete, let's look through the rest of the template to make sense of the rest...

## The Template builder definition

You'll notice our `builders` section is an array with a single object: our single AWS AMI builder definition. This is where we configure the underlying builder to do it's thing, telling it what we want to build, and the base from which we're building our final artifact:

```json
"name": "{{ user `username` }}-first-ami"
```
We're using built-in template interpolation to generate our `name` property. Again, name is only used internally and for Packer output.

```json
"type": "amazon-ebs"
```
This tells Packer the type of builder to use

```json
"access_key": "{{user `aws_access_key`}}",
"secret_key": "{{user `aws_secret_key`}}",
```
This type of builder exposes these properties so that we can pass in credentials for authenticating to AWS. Again, the builder can determine configured credentials on the machine such as the environment variables directly or an AWS CLI profile.

```json
"region": "us-west-1",
"source_ami": "ami-0dd655843c87b6930",
```
This tells Packer that we want to spin up our build machine with this `source_ami` as the base image, the one to build upon. So, we'll build our custom/final AMI from this AMI. It happens to be a standard Ubuntu AMI in the us-west-1 region. `region` instructs AWS to create our final AMI in the us-west-1 region. It's worth noting that Packer has some ways to create identical AMIs in a number of regions at a time using a builder (one of which is [a copy feature](https://www.packer.io/docs/builders/amazon-ebs.html#ami_regions))

```json
"instance_type": "t2.micro",
"ssh_username": "ubuntu",
```
The instance type to use for our builder EC2 instance. And the username that Packer should use to connect to the instance in the case of running provisioners. Being our first example, we're not yet including any provisioners in our template defintion. But, if we were, Packer would use this username to connect. AWS, depending on the type of distro underlying, has some specific standards for default machine users/usernames set up. E.g. Amazon Linux distro images would use `ec2-user` here instead of `ubuntu`.

```json
"ami_name": "{{ user `username` }}-first-ami"
```
And finally, we're telling Packer what to call the artifact AMI image ultimately created in our AWS account. We're interpolating the provided user variable here so that you all don't have conflicting AMI names being created at the same time.

## Back to the `build` output

Your `build` operation should be just about finished at this point, so let's switch back to the output of it to look through a few things there. It should look something like:

```bash
$ packer build -var username=force ./template.json
force-first-ami: output will be in this color.

==> force-first-ami: Prevalidating any provided VPC information
==> force-first-ami: Prevalidating AMI Name: force-first-ami
    force-first-ami: Found Image ID: ami-0dd655843c87b6930
==> force-first-ami: Creating temporary keypair: packer_5e3775d3-148d-0e42-7420-090998d223a9
==> force-first-ami: Creating temporary security group for this instance: packer_5e3775d5-a3f5-e508-3862-e7bcc7554487
==> force-first-ami: Authorizing access to port 22 from [0.0.0.0/0] in the temporary security groups...
==> force-first-ami: Launching a source AWS instance...
==> force-first-ami: Adding tags to source instance
    force-first-ami: Adding tag: "Name": "Packer Builder"
    force-first-ami: Instance ID: i-0c64ec7fe636a3a85
==> force-first-ami: Waiting for instance (i-0c64ec7fe636a3a85) to become ready...
==> force-first-ami: Using ssh communicator to connect: 54.241.129.65
==> force-first-ami: Waiting for SSH to become available...
==> force-first-ami: Connected to SSH!
==> force-first-ami: Stopping the source instance...
    force-first-ami: Stopping instance
==> force-first-ami: Waiting for the instance to stop...
==> force-first-ami: Creating AMI force-first-ami from instance i-0c64ec7fe636a3a85
    force-first-ami: AMI: ami-09169aeaaf07ad959
==> force-first-ami: Waiting for AMI to become ready...
==> force-first-ami: Terminating the source AWS instance...
==> force-first-ami: Cleaning up any extra volumes...
==> force-first-ami: No volumes to clean up, skipping
==> force-first-ami: Deleting temporary security group...
==> force-first-ami: Deleting temporary keypair...
Build 'force-first-ami' finished.

==> Builds finished. The artifacts of successful builds are:
--> force-first-ami: AMIs were created:
us-west-1: ami-09169aeaaf07ad959
```

We can identify a number of things from this output, importantly:

* `Prevalidating` tells us that Packer is doing some initial work to ensure that our template, build instructions, etc. make sense and are valid. In this case, that our `ami_name` rendered value is an allowed name in AWS.
* We see some indication that Packer is setting up some things in AWS to ensure the build or builds can complete successfully: a security group and key pair that allows for SSH connectivity to the build EC2 instance from our remote location in the case of needing to run provisioners.
* It's tagging the builder instance for internal and meta use
* Even though we aren't including a provisioner, the normal flow still runs some checks for the communicator being used by the builder to ensure SSH connectivity is possible/successful.
* And we can then see a number of different steps to automate stopping the instance, creating the AMI from the stopped instance's disk, and cleaning up items that were created like the security group and key pair

If you'd like to verify that your AMI was successfully created, you can do so from the AWS EC2 console. Once you're satisfied, you should be ready to move on. Delete your created AMI through the console if you have time, as it will help your instructor later on :)
