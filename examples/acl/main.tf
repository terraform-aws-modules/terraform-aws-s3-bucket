provider "aws" {
  region = local.region
}

locals {
  region = "eu-west-1"
  name   = "ex-${basename(path.cwd)}"

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-s3-bucket"
  }
}

data "aws_canonical_user_id" "current" {}

data "aws_cloudfront_log_delivery_canonical_user_id" "cloudfront" {}

################################################################################
# ACLs
################################################################################

# AWS recommends disabling ACLs, and the module defaults `object_ownership` to
# BucketOwnerEnforced, which rejects `acl`, `grant` and `owner` outright. This example exists
# for the workloads that still need them, chiefly CloudFront standard logging (legacy), which
# writes with a canonical user grant. Standard logging (v2) uses a bucket policy instead and
# needs none of this.
# https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices.html
# https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/standard-logging-legacy-s3.html

module "acl_canned" {
  source = "../../"

  bucket_prefix = "${local.name}-canned-"

  # `acl` conflicts with `grant` and `owner`
  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"
  acl                      = "private"

  # For example only
  force_destroy = true

  tags = local.tags
}

module "cloudfront_log_bucket" {
  source = "../../"

  bucket_prefix            = "${local.name}-cf-logs-"
  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  grant = [{
    type       = "CanonicalUser"
    permission = "FULL_CONTROL"
    id         = data.aws_canonical_user_id.current.id
    }, {
    type       = "CanonicalUser"
    permission = "FULL_CONTROL"
    id         = data.aws_cloudfront_log_delivery_canonical_user_id.cloudfront.id
    }
  ]

  owner = {
    id = data.aws_canonical_user_id.current.id
  }

  # For example only
  force_destroy = true

  tags = local.tags
}

# Object ACLs are only accepted where the bucket has ACLs enabled
module "object_acl" {
  source = "../../modules/object"

  region = local.region

  bucket = module.acl_canned.s3_bucket_id
  key    = "${local.name}-object"

  content = "some-content"
  acl     = "bucket-owner-full-control"

  # For example only
  force_destroy = true

  tags = local.tags
}
