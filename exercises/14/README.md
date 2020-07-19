# Exercise 14: Provisioners and Post-processors

Provisioners are the key to getting your machine images built in the way you need. Just like running infrastructure provisioning outside of Packer, it's how your server truly becomes a server useful to your needs.

## Using the builder type `null` for testing provisioners

We're going to use the first part of this exercise exploring a new built-in type of builder for Packer: [null](https://packer.io/docs/builders/null.html)

This type of builder is a great way to just see provisioners in action for the first time. Let's first look at our template `template-null-builder.json`:

```json
{
  "builders": [
    {
      "type": "null",
      "communicator": "none"
    }
  ],
  "provisioners": [
    {
      "type": "shell-local",
      "script": "./shell-local.sh"
    }
  ]
}
```

So, we're instructing Packer to use the `null` builder, no communicator so it will not attempt to make a connection to our builder resource. Finally, we're telling our builder to run a local script as its single provisioner. This template, in short, will simply run the script `./shell-local.sh` on our machine.

```bash
$ packer build template-null-builder.json
null: output will be in this color.

==> null: Running local shell script: ./shell-local.sh
    null: Starting our provisioner...
    null: Finished our provisioner
Build 'null' finished.

==> Builds finished. The artifacts of successful builds are:
--> null: Did not export anything. This is the null builder
```

In the output, we can see some info related to using our `null` builder specifically. We also get some feedback from Packer that is the output of our provisioning script. Let's look at the content of that script:

```bash
#!/bin/bash

echo "Starting our provisioner..."

echo "Finished our provisioner"
```

A very simple example, but one that allows us to verify that Packer actually executed the script, and we can see the output of it. We'll get to try out a more complex one here in a bit, but we want to try out post-processors first

## A simple post-processor exercise

We'll not spend a ton of time with hands-on post-processors, but we should have a little at least. We mentioned before that the `file` builder type is particularly useful in testing out post-processors. So, let's use it to test a post-processor that will create a checksum of our generated artifact. Let's look at our template `template-post-processors.json` first:

```json
{
  "builders": [
    {
      "type": "file",
      "content": "artifact",
      "target": "./artifact.txt"
    }
  ],
  "post-processors": [
    {
      "type": "checksum",
      "output": "./artifact.sum"
    }
  ]
}
```

This template will tell Packer to first create our artifact, `artifact.txt`. The content of which will be "artifact". Packer will then take this output artifact and use our single defined post-processor to generate a checksum for this artifact. Let's get to it and see what it actually does:

```bash
$ packer build template-post-processors.json
file: output will be in this color.

==> file: Running post-processor: checksum
Build 'file' finished.

==> Builds finished. The artifacts of successful builds are:
--> file: Stored file: ./artifact.txt
--> file: Created artifact from files: ./artifact.txt, ./artifact.sum
```

Again, Packer gives us some handy output to tell us what is happening, and the outcome of our build. We can see that we've run a file builder to create `./artifact.txt`. We can also verify that our post-processor did indeed run, as we see `./artifact.sum` referenced as well. Let's look at the content of that sum file as our final step of verifying that we have what we need:

```bash
$ cat ./artifact.sum
8e5b948a454515dbabfc7eb718daa52f	artifact.txt
```

A checksum was created by our post-processor, so we're good to go. Let's move onto the final part of our exercise.

## Building a custom AMI in AWS

Remember our first Terraform experiment for bringing up an web server in AWS? We're going to use the rest of this exercise to do that same thing again.

Except, we want to create/pre-provision a custom AMI using Packer that will run what you need it to run instead of simply bringing up an EC2 instance and provisioning it at runtime. Bring this custom AMI up with Terraform to enable a fully-functioning web server when the EC2 instance is created.

As a reminder on the few details of that previous exercise:

* Provision this instance to install some web server
* Make sure we can access the web server from the outside world
* Use online docs for help, use each other, and I’m here too if you need!
