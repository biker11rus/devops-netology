provider "aws" {
    profile = "terraform"
    shared_credentials_file = "/home/rkhozyainov/.aws/credentials"
    region  = "us-west-1"
}
resource "aws_s3_bucket" "terraform_state" {
    bucket = "rkh-terraform-state"
    force_destroy = true
    versioning {
          enabled = true
      }
}
resource "aws_dynamodb_table" "terraform_locks" {
    name = "rkh-terraform-state-locks"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"
    
    attribute {
        name = "LockID"
        type = "S"
    }
}
terraform {
    backend "s3" {
    bucket = "rkh-terraform-state"
    key = "global/s3/terraform.tfstate"
    region = "us-west-1"
    dynamodb_table = "rkh-terraform-state-locks"
    encrypt = true
    profile = "terraform"
  }
}