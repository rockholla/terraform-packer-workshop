# terraform import example

see https://www.terraform.io/docs/import/usage.html for more info

```
Usage: terraform import [options] ADDR ID

  Import existing infrastructure into your Terraform state.

  This will find and import the specified resource into your Terraform
  state, allowing existing infrastructure to come under Terraform
  management without having to be initially created by Terraform.

  The ADDR specified is the address to import the resource to. Please
  see the documentation online for resource addresses. The ID is a
  resource-specific ID to identify that resource being imported. Please
  reference the documentation for the resource type you're importing to
  determine the ID syntax to use. It typically matches directly to the ID
  that the provider uses.

  The current implementation of Terraform import can only import resources
  into the state. It does not generate configuration. A future version of
  Terraform will also generate configuration.

  Because of this, prior to running terraform import it is necessary to write
  a resource configuration block for the resource manually, to which the
  imported object will be attached.

  This command will not modify your infrastructure, but it will make
  network requests to inspect parts of your infrastructure relevant to
  the resource being imported.
```

```
$ terraform import aws_instance.example i-abcd1234
```

So, for the above, `aws_instance.example` would be the `ADDR` mentioned in the help. It will ensure that the resource block of type `aws_instance`, identifier `example` will be used as the configuration item in state. You'll still have to build out the configuration block yourself, `import` will only import info into state.

`i-abcd1234` is the EC2 instance ID. This allows terraform to identify the actual piece of infrastructure, the instance, in AWS so that it can get info about it to import into state.
