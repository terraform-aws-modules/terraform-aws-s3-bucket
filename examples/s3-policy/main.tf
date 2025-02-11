provider "aws" {
  region = local.region

  # Improve speed by skipping unnecessary checks
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
}

locals {
  bucket_name    = "s3-bucket-${random_pet.this.id}"
  region         = "eu-west-1"
  create_bucket  = false
  attach_policy  = true
  force_destroy  = true
  versioning     = true
  enable_logging = true
  acl           = "private"
}

resource "random_pet" "this" {
  length = 2
}

data "aws_caller_identity" "current" {}

data "aws_canonical_user_id" "current" {}

resource "aws_iam_role" "this" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# S3 Bucket Policy Document
data "aws_iam_policy_document" "bucket_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.this.arn]
    }

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${local.bucket_name}",
    ]
  }
}

# S3 Bucket Module
module "s3_bucket" {
  source = "../../"

  create_bucket = local.create_bucket
  bucket        = local.bucket_name

  attach_policy = local.attach_policy
  policy        = data.aws_iam_policy_document.bucket_policy.json

  force_destroy = local.force_destroy
  versioning    = { enabled = local.versioning }

  tags = {
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}