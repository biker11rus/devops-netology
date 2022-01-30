terraform {
  backend "s3" {
    bucket = "rkh-terraform-state"
    key = "rkh-workspacec/terraform.tfstate"
    region = "us-west-1"
    dynamodb_table = "rkh-terraform-state-locks"
    encrypt = true
    profile = "terraform"
  }
}
provider "aws" {
  profile = "terraform"
  shared_credentials_file = "/home/rkhozyainov/.aws/credentials"
  region  = "us-west-1"
}
data "aws_ami" "last-ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
    }

  owners = ["099720109477"] # Canonical
}

locals {
      instance_type = {
          stage = "t2.micro"
          prod = "t2.micro"
      }
      instance_count = {
        stage = 1
        prod = 2
      }
      instances = {
          "t2.micro" = data.aws_ami.last-ubuntu.id
          "t2.micro" = data.aws_ami.last-ubuntu.id
      }
    }
resource "aws_instance" "test" {
    ami           = data.aws_ami.last-ubuntu.id
    instance_type = local.instance_type[terraform.workspace]
    count = local.instance_count[terraform.workspace]
    tags = {
    Name = "test-ubuntu"
  }
}
resource "aws_instance" "test2" {
    for_each = local.instances

    ami           = each.value
    instance_type = each.key

    lifecycle {
    create_before_destroy = true
    }
}


data "aws_caller_identity" "test_call_id" {}
data "aws_region" "test_reg" {}

