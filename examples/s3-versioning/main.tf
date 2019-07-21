variable "region" {
  default = "us-west-2"
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

// Calling module:

module "aws_s3_bucket" {
  source = "../.."
  bucket = "s3-tf-example-versioning"
  acl    = "private"

  versioning_inputs = [
    {
      enabled    = true
      mfa_delete = null
    },
  ]


}