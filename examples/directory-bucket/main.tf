locals {
  region = "eu-west-1"
}

provider "aws" {
  region = local.region

  # Make it faster by skipping something
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

module "simple" {
  source = "../../"

  is_directory_bucket = true
  bucket              = random_pet.this.id
  # https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-express-Endpoints.html
  availability_zone_id = data.aws_availability_zones.available.zone_ids[1]
}

module "complete" {
  source = "../../"

  is_directory_bucket = true
  bucket              = "${random_pet.this.id}-complete"
  # https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-express-Endpoints.html
  availability_zone_id = data.aws_availability_zones.available.zone_ids[1]
  server_side_encryption_configuration = {
    rule = {
      bucket_key_enabled = true # required for directory buckets
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_key.objects.arn
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

  metric_configuration = {
    all_objects = {
      name = "AllObjects"
    },
    logs = {
      name = "Logs"
      filter = {
        prefix = "logs/"
      }
    }
  }

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

resource "random_pet" "this" {
  length = 2
}

resource "aws_kms_key" "objects" {
  description             = "KMS key is used to encrypt bucket objects"
  deletion_window_in_days = 7
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

module "inventory_destination_bucket" {
  source = "../../"

  bucket = "${random_pet.this.id}-inventory-destination-bucket"
  # https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-express-Endpoints.html
  availability_zone_id = data.aws_availability_zones.available.zone_ids[1]
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
}

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
