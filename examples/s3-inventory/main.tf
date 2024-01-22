locals {
  bucket_name = "s3-bucket-${random_pet.this.id}"
  region      = "eu-west-1"
}

provider "aws" {
  region = local.region

  # Make it faster by skipping something
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
}

data "aws_caller_identity" "current" {}

module "multi_inventory_configurations_bucket" {
  source = "../../"

  bucket = local.bucket_name

  force_destroy = true

  attach_policy                       = true
  attach_inventory_destination_policy = true
  inventory_self_source_destination   = true
  acl                                 = "private" # "acl" conflicts with "grant" and "owner"

  versioning = {
    status     = true
    mfa_delete = false
  }

  inventory_configuration = {

    # Same source and destination buckets
    daily = {
      included_object_versions = "Current"
      destination = {
        format = "CSV"
        encryption = {
          encryption_type = "sse_kms"
          kms_key_id      = module.kms.key_arn
        }
      }
      filter = {
        prefix = "documents/"
      }
      frequency = "Daily"
    }

    weekly = {
      included_object_versions = "All"
      destination = {
        format = "CSV"
      }
      frequency = "Weekly"
    }

    # Different destination bucket
    destination_other = {
      included_object_versions = "All"
      destination = {
        bucket_arn = module.inventory_destination_bucket.s3_bucket_arn
        format     = "Parquet"
        encryption = {
          encryption_type = "sse_s3"
        }
      }
      frequency       = "Weekly"
      optional_fields = ["Size", "EncryptionStatus", "StorageClass", "ChecksumAlgorithm"]
    }

    # Different source bucket
    source_other = {
      included_object_versions = "Current"
      bucket                   = module.inventory_source_bucket.s3_bucket_id
      destination = {
        format = "ORC"
        encryption = {
          encryption_type = "sse_s3"
        }
      }
      frequency = "Daily"
    }
  }
}

resource "random_pet" "this" {
  length = 2
}

# https://docs.aws.amazon.com/AmazonS3/latest/userguide/configure-inventory.html#configure-inventory-kms-key-policy
module "kms" {
  source = "terraform-aws-modules/kms/aws"

  description             = "Key example for Inventory S3 destination encyrption"
  deletion_window_in_days = 7
  key_statements = [
    {
      sid = "s3InventoryPolicy"
      actions = [
        "kms:GenerateDataKey",
      ]
      resources = ["*"]

      principals = [
        {
          type        = "Service"
          identifiers = ["s3.amazonaws.com"]
        }
      ]

      conditions = [
        {
          test     = "StringEquals"
          variable = "aws:SourceAccount"
          values = [
            data.aws_caller_identity.current.id,
          ]
        },
        {
          test     = "ArnLike"
          variable = "aws:SourceARN"
          values = [
            module.inventory_source_bucket.s3_bucket_arn,
            module.multi_inventory_configurations_bucket.s3_bucket_arn
          ]
        }
      ]
    }
  ]
}

module "inventory_destination_bucket" {
  source = "../../"

  bucket                              = "inventory-destination-${random_pet.this.id}"
  acl                                 = "private" # "acl" conflicts with "grant" and "owner"
  force_destroy                       = true
  attach_policy                       = true
  attach_inventory_destination_policy = true
  inventory_source_bucket_arn         = module.multi_inventory_configurations_bucket.s3_bucket_arn
  inventory_source_account_id         = data.aws_caller_identity.current.id
}

module "inventory_source_bucket" {
  source = "../../"

  bucket        = "inventory-source-${random_pet.this.id}"
  acl           = "private" # "acl" conflicts with "grant" and "owner"
  force_destroy = true
}
