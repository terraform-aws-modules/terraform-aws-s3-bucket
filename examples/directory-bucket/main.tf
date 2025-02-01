locals {
  region  = "eu-west-1"
  zone_id = "euw1-az1"
}

provider "aws" {
  region = local.region

  # Make it faster by skipping something
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
}

data "aws_caller_identity" "current" {}

module "directory_bucket" {
  source = "../../modules/directory-bucket"

  bucket_name_prefix   = random_pet.this.id
  availability_zone_id = local.zone_id

  server_side_encryption_configuration = {
    sse_algorithm     = "aws:kms"
    kms_master_key_id = aws_kms_key.objects.id
  }

  lifecycle_rules = {
    all = {
      id     = "test"
      status = "Enabled"
      abort_incomplete_multipart_upload = {
        days_after_initiation = 7
      }
      expiration = {
        days = 7
      }
    },
    logs = {
      status = "Enabled"
      expiration = {
        days = 5
      }
      filter = {
        prefix                = "logs/"
        object_size_less_than = 10
      }
    },
    other = {
      id     = "other"
      status = "Enabled"
      expiration = {
        days = 2
      }
      filter = {
        prefix = "other/"
      }
    }
  }

  create_bucket_policy = true
  policy_statements = {
    write = {
      sid    = "ReadWriteAccess"
      effect = "Allow"

      actions = [
        "s3express:CreateSession",
      ]

      principals = [
        {
          type        = "AWS"
          identifiers = [data.aws_caller_identity.current.account_id]
        }
      ]
    }
    readonly = {
      sid    = "ReadOnlyAccess"
      effect = "Allow"

      actions = [
        "s3express:CreateSession",
      ]

      principals = [
        {
          type        = "AWS"
          identifiers = [data.aws_caller_identity.current.account_id]
        }
      ]

      conditions = [
        {
          test     = "StringEquals"
          values   = ["ReadOnly"]
          variable = "s3express:SessionMode"
        }
      ]
    }
  }
}

resource "random_pet" "this" {
  length = 2
}

resource "aws_kms_key" "objects" {
  description             = "KMS key is used to encrypt bucket objects"
  deletion_window_in_days = 7
}
