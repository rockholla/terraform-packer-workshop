locals {
  env = {
    dev = {
      region = "us-west-1"
    }
    prod = {
      region = "us-east-2"
    }
  }
}

provider "aws" {
  version = "~> 2.0"
  region  = local.env[terraform.workspace].region
}

provider "template" {
  version ="~> 2.1"
}
