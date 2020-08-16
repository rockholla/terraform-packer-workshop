provider "aws" {
  version = "~> 2.0"
  region  = "${var.region}"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "force_nginx" {
  name        = "force_nginx_firewall"
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

resource "tls_private_key" "nginx_server" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "nginx_server" {
  key_name   = "force_nginx_server"
  public_key = "${tls_private_key.nginx_server.public_key_openssh}"
}

resource "aws_instance" "nginx_server" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"

  key_name = "${aws_key_pair.nginx_server.key_name}"

  security_groups = ["${aws_security_group.force_nginx.name}"]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = "${self.public_ip}"
      user        = "ubuntu"
      private_key = "${tls_private_key.nginx_server.private_key_pem}"
    }
    scripts = ["./provisioner.sh"]
  }

  tags = {
    Name = "force-nginx-server"
  }
}