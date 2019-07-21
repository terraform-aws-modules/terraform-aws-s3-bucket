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
  bucket = "s3-tf-example-cors"
  acl    = "private"

  cors_rule_inputs = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["PUT", "POST"]
      allowed_origins = ["https://s3-website-test.hashicorp.com", "https://s3-website-test.hashicorp.io"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    },
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET"]
      allowed_origins = ["https://s3-website-test.hashicorp.io"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    },
  ]

}