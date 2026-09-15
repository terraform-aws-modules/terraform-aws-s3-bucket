locals {
  name   = "ex-${basename(path.cwd)}"
  region = "eu-west-1"

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-s3-bucket"
  }
}

provider "aws" {
  region = local.region
}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

################################################################################
# Directory Bucket
################################################################################

module "simple" {
  source = "../../"

  is_directory_bucket = true
  bucket              = local.name
  # S3 Express One Zone is only offered in a subset of each region's Availability Zones, and
  # AWS publishes no API to discover which, so this cannot be derived. In eu-west-1 it is
  # euw1-az1 and euw1-az3; euw1-az2 rejects the create with InvalidBucketName.
  # https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-express-Endpoints.html
  availability_zone_id = data.aws_availability_zones.available.zone_ids[0]

  tags = local.tags
}

module "complete" {
  source = "../../"

  is_directory_bucket = true
  bucket              = "${local.name}-complete"
  # Not every AZ offers S3 Express One Zone; euw1-az2 rejects the create
  # https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-express-Endpoints.html
  availability_zone_id = data.aws_availability_zones.available.zone_ids[0]
  location_type        = "AvailabilityZone"
  data_redundancy      = "SingleAvailabilityZone"
  server_side_encryption_configuration = {
    rule = {
      bucket_key_enabled = true # required for directory buckets
      apply_server_side_encryption_by_default = {
        kms_master_key_id = module.kms.key_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  lifecycle_rule = [
    {
      id     = "test"
      status = "Enabled"
      expiration = {
        days = 7
      }
    },
    {
      id     = "logs"
      status = "Enabled"
      expiration = {
        days = 5
      }
      filter = {
        prefix                = "logs/"
        object_size_less_than = 10
      }
    },
    {
      id     = "other"
      status = "Enabled"
      expiration = {
        days = 2
      }
      filter = {
        prefix = "other/"
      }
    }
  ]
  attach_policy = true
  policy        = data.aws_iam_policy_document.bucket_policy.json

  metric_configuration = [
    {
      name = "AllObjects"
    },
    {
      name = "Logs"
      filter = {
        prefix = "logs/"
      }
    }
  ]

  inventory_configuration = {
    weekly = {
      included_object_versions = "All"
      destination = {
        bucket_arn = module.inventory_destination_bucket.s3_bucket_arn
        format     = "Parquet"
        encryption = {
          encryption_type = "sse_s3"
        }
      }
      filter = {
        prefix = "documents/"
      }
      frequency       = "Weekly"
      optional_fields = ["Size", "EncryptionStatus", "StorageClass", "ChecksumAlgorithm"]
    }
  }

  tags = {
    directory-bucket = true
  }
}

module "inventory_destination_bucket" {
  source = "../../"

  bucket = "${local.name}-inventory-destination-bucket"
  # Not every AZ offers S3 Express One Zone; euw1-az2 rejects the create
  # https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-express-Endpoints.html
  availability_zone_id = data.aws_availability_zones.available.zone_ids[0]
  server_side_encryption_configuration = {
    rule = {
      bucket_key_enabled = true # required for directory buckets
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
  attach_policy = true
  policy        = data.aws_iam_policy_document.destination_bucket_policy.json

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

data "aws_iam_policy_document" "destination_bucket_policy" {

  statement {
    sid    = "InventoryDestination"
    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = ["${module.inventory_destination_bucket.s3_bucket_arn}/*"]

    principals {
      identifiers = ["s3express.amazonaws.com"]
      type        = "Service"
    }

    condition {
      test     = "ArnLike"
      values   = [module.complete.s3_directory_bucket_arn]
      variable = "aws:SourceARN"
    }

    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "aws:SourceAccount"
    }

    condition {
      test     = "StringEquals"
      values   = ["bucket-owner-full-control"]
      variable = "s3:x-amz-acl"
    }
  }
}

module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 4.0"

  description             = "KMS key is used to encrypt bucket objects"
  deletion_window_in_days = 7

  tags = local.tags
}

data "aws_iam_policy_document" "bucket_policy" {

  statement {
    sid    = "ReadWriteAccess"
    effect = "Allow"

    actions = [
      "s3express:CreateSession",
    ]

    resources = [module.complete.s3_directory_bucket_arn]

    principals {
      identifiers = [data.aws_caller_identity.current.account_id]
      type        = "AWS"
    }
  }

  statement {
    sid    = "ReadOnlyAccess"
    effect = "Allow"

    actions = [
      "s3express:CreateSession",
    ]

    resources = [module.complete.s3_directory_bucket_arn]

    principals {
      identifiers = [data.aws_caller_identity.current.account_id]
      type        = "AWS"
    }

    condition {
      test     = "StringEquals"
      values   = ["ReadOnly"]
      variable = "s3express:SessionMode"
    }
  }
}
