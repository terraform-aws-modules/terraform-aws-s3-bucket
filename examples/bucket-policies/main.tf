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

data "aws_caller_identity" "current" {}

################################################################################
# Bucket Policies
################################################################################

# Every policy the module can attach, on one bucket. Each `attach_*` toggle appends a
# statement to a single merged bucket policy, so they compose rather than conflict.
module "s3_bucket" {
  source = "../../"

  bucket_prefix = "${local.name}-"

  # For example only
  force_destroy = true

  # Server access logs are delivered to the bucket below, which carries the matching
  # attach_access_log_delivery_policy
  logging = {
    target_bucket = module.log_bucket.s3_bucket_id
    target_prefix = "log/"
    target_object_key_format = {
      partitioned_prefix = {
        partition_date_source = "DeliveryTime"
      }
    }
  }

  attach_policy                             = true
  policy                                    = data.aws_iam_policy_document.bucket_policy.json
  attach_deny_insecure_transport_policy     = true
  attach_require_latest_tls_policy          = true
  attach_deny_incorrect_encryption_headers  = true
  attach_deny_incorrect_kms_key_sse         = true
  allowed_kms_key_arn                       = module.kms.key_arn
  attach_deny_unencrypted_object_uploads    = true
  attach_deny_ssec_encrypted_object_uploads = true

  tags = local.tags
}

################################################################################
# Log Delivery
################################################################################

# The log delivery policies are separate because they are attached to the bucket that
# *receives* logs, not the one that produces them.
module "log_bucket" {
  source = "../../"

  bucket_prefix = "${local.name}-logs-"

  # For example only
  force_destroy = true

  control_object_ownership = true

  attach_elb_log_delivery_policy        = true
  attach_lb_log_delivery_policy         = true
  attach_access_log_delivery_policy     = true
  attach_cloudtrail_log_delivery_policy = true
  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true
  attach_waf_log_delivery_policy        = true

  access_log_delivery_policy_source_accounts      = [data.aws_caller_identity.current.account_id]
  access_log_delivery_policy_source_buckets       = [module.s3_bucket.s3_bucket_arn]
  access_log_delivery_policy_source_organizations = ["o-123456"]
  lb_log_delivery_policy_source_organizations     = ["o-123456"]

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

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
      module.s3_bucket.s3_bucket_arn,
    ]
  }

  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.this.arn]
    }

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "_S3_BUCKET_ARN_",
    ]

    condition {
      test     = "StringNotEquals"
      variable = "aws:PrincipalAccount"
      values   = ["_AWS_ACCOUNT_ID_"]
    }
  }
}

module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 4.0"

  description             = "Key example for S3 bucket policies"
  deletion_window_in_days = 7

  tags = local.tags
}
