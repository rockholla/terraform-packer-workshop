provider "aws" {
  version = "~> 2.0"
  region  = "${var.region}"
}

data "aws_ami" "nginx_server" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${var.ami_name}"]
  }

  owners = ["self"] # rockholla-di
}

resource "aws_security_group" "nginx_server" {
  name        = "force-nginx-server-firewall-alt"
  description = "Firewall for the force-nginx-server"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nginx_server" {
  ami           = "${data.aws_ami.nginx_server.id}"
  instance_type = "t2.micro"

  security_groups = ["${aws_security_group.nginx_server.name}"]

  tags = {
    Name = "force-nginx-server"
  }
}