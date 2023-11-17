locals {
  bucket_name = "known-name"
}
provider "aws" {
  region = "eu-west-1"
}

module "simple_bucket" {
  source = "../../"

  bucket = local.bucket_name

  force_destroy = true
}