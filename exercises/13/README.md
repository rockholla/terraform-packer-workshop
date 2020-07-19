# Exercise 13: Messing with Packer

We had a first Packer exercise with the most basic template possible, a build created for you. We were able to get a glimpse of some deeper capabilities, but we want to use this exercise to go even deeper. And use some edge capabilities to experiment with variables and see Packer's internals with a little more clarity.

## The `file` builder

The `file` builder is one that is provided by Packer, and isn't very useful except for being able to debug. And, maybe most importantly, to debug quickly. In most cases, Packer is all about trying to create artifacts by spinning up full Virtual Machines, provisioning those machines, and then creating the artifact from those machines. This means that errors can be costly at times. Maybe you get part of the way through your build, only to discover you made a simple mistake in how you set up your variables or some other part of your template, provisioning scripts or similar.

The primary practical use for the `file` provisioner is to debug post-processors without having to wait to get to them.

So, we'll use the `file` provisioner to demonstrate its use for such things as well as just being able to mess around with Packer a bit more.

Let's start by running the default build of our `template.json` file here. First, by looking at its contents:

```json
{
  "variables": {
    "content": ""
  },
  "builders": [
    {
      "type": "file",
      "content": "{{ user `content` }}",
      "target": "./artifact.txt"
    }
  ],
  "provisioners": [
    {
      "type": "shell",
      "inline": ["echo 'building...'"]
    }
  ]
}
```

Our `content` variable has a default value of "". Remember from our previous exercise, that we could set this default value to `null` instead to make it a required variable, but we'll default it to a blank string for the case of our exercise.

Before we go further, what do you expect this defintion to do? Are you able to start seeing how Packer works well enough to make an educated guess?

Let's run our build and see what we get

```bash
$ packer build ./template.json
file: output will be in this color.

Warnings for build 'file':

* Both source file and contents are blank; target will have no content

Build 'file' finished.

==> Builds finished. The artifacts of successful builds are:
--> file: Stored file: ./artifact.txt
```

Pretty simple in comparison to our AWS build from the last exercise. We do see one interesting thing in the Packer output here: `Both source file and contents are blank; target will have no content`. This is telling us that we're creating an empty artifact at `./artifact.txt`. Is that what you guess would happen? Let's see the difference if we give our artifact file some content:

```bash
$ packer build -var content=1010001010111 ./template.json
file: output will be in this color.

Build 'file' finished.

==> Builds finished. The artifacts of successful builds are:
--> file: Stored file: ./artifact.txt
```

We no longer get the warning, and let's see what's in our `./artifact.txt` file now:

```bash
cat ./artifact.txt
1010001010111
```

Exactly what we passed as the variable value, so we can see this value being passed through the resulting artifact content by way of our `file` builder.

## Checking out our `template.json` again

```json
{
  "variables": {
    "content": ""
  },
  "builders": [
    {
      "type": "file",
      "content": "{{ user `content` }}",
      "target": "./artifact.txt"
    }
  ],
  "provisioners": [
    {
      "type": "shell",
      "inline": ["echo 'building...'"]
    }
  ]
}
```

As we look more closely at our template, you might notice something new here: we've added a provisioner to our template for the first time. Can you think of anything odd or questionable in relation to our results from the exercise so far?

We had no indication that a provisioner was even part of our template based on the output. The `file` builder is dead simple, again it's use is really just for debugging and testing out post-processors. The provisioner we've included here tells Packer to use the provisioner type `shell`, which is a provisioner type that must have a connection via the builder's communicator to some place to run the provisioner. The `file` builder type has no ability to "connect" via it's communicator, thus the idea of running the remote "shell" provisioner type doesn't make sense. Packer just silently moves past these sorts of things, no provisioner run, no error.

After thinking through the above paragraph, is there a provisioner we might be able to use that would run with the `file` builder type? Some provisioners run on the machine executing Packer instead of connecting to the build resource/machine to run. One example is the provisioner type "shell-local." Try changing the provisioner type and see what happens when you execute `packer build template.json` again.

In the next section of the course, we'll take a closer look at provisioners, so we can move on for now.

## A look at the `build -debug` argument

We've already talked about the potential of incurring lost time to discover errors in your Packer builds, logic, templates, etc. There's another method to help you lose less time and track down problems more quickly: the `build -debug` argument. Let's just try it out using the file provisioner to get an idea of what it's capable of doing for us:

```bash
$ packer build -debug ./template.json
Debug mode enabled. Builds will not be parallelized.
file: output will be in this color.

Warnings for build 'file':

* Both source file and contents are blank; target will have no content

==> file: Pausing before the next provisioner . Press enter to continue.
```

We can see that Packer is generically capable of pausing before running a provisioner. This gives us the ability to debug what's happening in real-time when building an image. Suppose, say our second provisioner was failing and we didn't know why. Could it be something that our first provisioner did? This gives us a quick way of stepping through possible problems causing our issue without having to guess at the fix and just running a whole build again with our fingers crossed.

What would happen if we removed the provisioners entirely from this template and re-ran again with `-debug`?

## Another template to look at built-in functions and their complexity

Where Hashicorp tools start to become too mysterious and un-documented are at the edges of their functionality. Packer is no exception. We have another template in this exercise to demonstrate this purpose

```bash
$ packer build ./template-functions.json
file: output will be in this color.

Build 'file' finished.

==> Builds finished. The artifacts of successful builds are:
--> file: Stored file: ./artifact-functions.txt
Patricks-MacBook-Pro:13 patrickforce$ cat ./artifact-functions.txt
VAR-1
```

If we look at the contents of the template:

```json
{
  "variables": {
    "content": "var-1"
  },
  "builders": [
    {
      "type": "file",
      "content": "{{ user `content` | replace \"var\" \"VAR\" -1 }}",
      "target": "./artifact-functions.txt"
    }
  ]
}
```

So, we have a slightly different template here to play with the built-in function `replace`. It's one, in my experience, that is under-documented. Especially in relation to using with other dynamic values, so getting a chance to see and work with this one specifically is useful.

*NOTE: Hashicorp has some documentation in a few cases like the one mentioned above. Much of their documentation ends up being auto-generated, which is a very useful model for their business, but leaves us scratching our heads sometimes. Know that you're not the only one if you end up running into dead ends with Hashicorp tool documentation. Sometimes you just have to play to get your answer*

What our `template-functions.json` is doing is taking our `content` variable and passing it through the built-in `replace` function.

I encourage you to search for alternate ways to solve this same problem during our experimentation time. As mentioned in the note above, figuring out paths to solutions that are undocumented or under-documented will be the toughest part in your journey with Hashicorp tools like Terraform and Packer. It's worth getting used to it sooner rather than later.

## Playing with `validate`, `console`, etc.

If you have time, start playing around with the other Packer CLI commands we discussed against our `template.json` here, see what you get, what other questions you might be able to spark by starting to use them.

And with that, we should be good to move on. This exercise was all about tinkering, which is an important part of our work. It introduced us to provisioners for the first time. We'll spend the next section of the course diving further into both provisioners and post-processors.
