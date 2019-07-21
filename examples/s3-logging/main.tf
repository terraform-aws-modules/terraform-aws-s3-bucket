variable "region" {
  default = "us-west-2"
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

// Calling module:

module "log_bucket" {
  source = "../.."
  bucket = "s3-tf-example-logger"
  acl    = "log-delivery-write"


}

module "aws_s3_bucket" {
  source = "../.."
  bucket = "s3-tf-example-logging"
  acl    = "private"

  logging_inputs = [
    {
      target_bucket = "s3-tf-example-logger"
      target_prefix = "log/"
    },
  ]

}
