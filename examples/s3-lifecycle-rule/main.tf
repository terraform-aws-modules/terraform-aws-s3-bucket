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
  bucket = "s3-tf-example-lifecycle"
  acl    = "private"

  lifecycle_rule_inputs = [{
    id                                     = "log"
    enabled                                = true
    prefix                                 = "log/"
    abort_incomplete_multipart_upload_days = null
    tags = {
      "rule"      = "log"
      "autoclean" = "true"
    }

    expiration_inputs = [{
      days                         = 90
      date                         = null
      expired_object_delete_marker = null
      },
    ]
    transition_inputs                    = []
    noncurrent_version_transition_inputs = []
    noncurrent_version_expiration_inputs = []

    },
    {
      id                                     = "log1"
      enabled                                = true
      prefix                                 = "log1/"
      abort_incomplete_multipart_upload_days = null
      tags = {
        "rule"      = "log1"
        "autoclean" = "true"
      }

      expiration_inputs = []
      transition_inputs = []
      noncurrent_version_transition_inputs = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 60
          storage_class = "ONEZONE_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        },
      ]
      noncurrent_version_expiration_inputs = []
    },
  ]
}