# Exercise 15: Building Docker Images w/ Packer

As we discussed, building Docker images with Packer solves very specific needs. Writing Dockerfiles, building, and pushing container images is a much-more common approach and one that can be automated quite well. Nonetheless, we'll use this exercise to learn how to build docker images with Packer. We'll also get a chance to see some relevant post-processors for the builder.

## Building a Docker image with Packer

Let's begin here with looking at the template:

```json
{
  "builders": [
    {
      "type": "docker",
      "image": "alpine",
      "commit": true
    }
  ],
  "provisioners": [
    {
      "type": "shell",
      "inline": ["apk add nginx"]
    }
  ],
  "post-processors": [
    {
      "type": "docker-tag",
      "repository": "terraform-workshop/alpine-nginx",
      "tag": "0.0.1"
    }
  ]
}
```

With what we know of templates so far, we can pretty easily step through this and get an idea of what is actually going to happen here. There are definitely some quirks and oddities related to the `docker` builder type, but this is a pretty simple example. So, let's go through it.

First, our builder is one that Packer makes available to us by default with the distributed CLI. You can see more about the options available via this builder in [the official Packer documentation for the Docker builder](https://packer.io/docs/builders/docker.html).

We're taking the simplest possible approach with the builder definition in this exercise:

* `"image": "alpine"`: this is going to tell Packer to use the Docker Hub "alpine:latest" image as the base for our build. Much like we use a source AMI in AWS builds.
* `"commit": true"`: this tells Packer that we'll save the image to our local Docker daemon in preparation for whatever else we want to do like tagging, saving, pushing, etc.

Now, for the provisioner. This provisioner is almost identical to what we'd do in other builder types. Packer is using the builder type's communicator to get into the running local Docker container, then run's the provisioner we configured. In this case, we're telling Packer to run `apk add nginx`, or install nginx, in our running container. This provisioner is doing what a Dockerfile would do in other `docker build` scenarios.

Lastly, without a post-processor for the `docker` builder type, we're essentially just left with an unnamed/untagged image. So, we need to do something to make sure that Packer tags this image for us, at least, in our local Docker daemon. So, we provide the standard `docker-tag` post-processor to do so. The definition being pretty self-explanatory.

Let's go a ahead and run this and see what actually happens:

```bash
$ packer build template.json
docker: output will be in this color.

==> docker: Creating a temporary directory for sharing data...
==> docker: Pulling Docker image: alpine
    docker: Using default tag: latest
    docker: latest: Pulling from library/alpine
    docker: Digest: sha256:ab00606a42621fb68f2ed6ad3c88be54397f981a7b70a79db3d1172b11c4367d
    docker: Status: Image is up to date for alpine:latest
    docker: docker.io/library/alpine:latest
==> docker: Starting docker container...
    docker: Run command: docker run -v /Users/patrickforce/.packer.d/tmp480528331:/packer-files -d -i -t --entrypoint=/bin/sh -- alpine
    docker: Container ID: fadc305423e0557548a1de9df713e05105fa2916726fa8982bb2d790e83b691d
==> docker: Using docker communicator to connect: 172.17.0.2
==> docker: Provisioning with shell script: /var/folders/27/59b1yv5546j9zs8fbkx_tcjh0000gn/T/packer-shell360405911
    docker: fetch http://dl-cdn.alpinelinux.org/alpine/v3.11/main/x86_64/APKINDEX.tar.gz
    docker: fetch http://dl-cdn.alpinelinux.org/alpine/v3.11/community/x86_64/APKINDEX.tar.gz
    docker: (1/2) Installing pcre (8.43-r0)
    docker: (2/2) Installing nginx (1.16.1-r6)
    docker: Executing nginx-1.16.1-r6.pre-install
    docker: Executing busybox-1.31.1-r9.trigger
    docker: OK: 7 MiB in 16 packages
==> docker: Committing the container
    docker: Image ID: sha256:4ca66199286142ce134150882703c0546e89e82ffcffb7eb28813e453bdfcb7c
==> docker: Killing the container: fadc305423e0557548a1de9df713e05105fa2916726fa8982bb2d790e83b691d
==> docker: Running post-processor: docker-tag
    docker (docker-tag): Tagging image: sha256:4ca66199286142ce134150882703c0546e89e82ffcffb7eb28813e453bdfcb7c
    docker (docker-tag): Repository: terraform-workshop/alpine-nginx:0.0.1
Build 'docker' finished.

==> Builds finished. The artifacts of successful builds are:
--> docker: Imported Docker image: sha256:4ca66199286142ce134150882703c0546e89e82ffcffb7eb28813e453bdfcb7c
--> docker: Imported Docker image: terraform-workshop/alpine-nginx:0.0.1
```

Just a bit more here than we're used to seeing so far in Packer output, but familiar nonetheless. We can see a few important things in the output:

* The flow of Packer orchestrating local Docker operations, including creating the container in prep for provisioning it
* The communicator for the `docker` builder type is very unique and cannot be overridden
* We see the provisioner running
* The post-processor tagging is clear

We should now be able to look at our local Docker daemon and see the new image:

```bash
$ docker images | grep terraform-workshop
terraform-workshop/alpine-nginx   0.0.1               4ca661992861        5 minutes ago       8.57MB
```

Packer has successfully built an image for us, and it's now in our local Docker daemon. Packer has the ability to use other post-processors to automate other things as well such as:

* Docker importing
* Docker saving
* Docker pushing

See https://packer.io/docs/post-processors/index.html for more info. That gets us to where we need to be for this exercise though, so without further ado...

