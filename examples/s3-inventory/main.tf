locals {
  bucket_name = "s3-bucket-${random_pet.this.id}"
  region      = "eu-west-1"
}

provider "aws" {
  region = local.region

  # Make it faster by skipping something
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}

data "aws_caller_identity" "current" {}

resource "random_pet" "this" {
  length = 2
}

resource "aws_kms_key" "objects" {
  description             = "KMS key is used to encrypt bucket objects"
  deletion_window_in_days = 7
  policy                  = data.aws_iam_policy_document.inventory_kms_policy.json
}

# A kms key policy is required if using s3 aws:kms encryption for inventory reports
data "aws_iam_policy_document" "inventory_kms_policy" {
  statement {
    sid     = "s3InventoryPolicy"
    effect  = "Allow"
    actions = ["kms:GenerateDataKey"]
    principals {
      identifiers = ["s3.amazonaws.com"]
      type        = "Service"
    }
    resources = ["*"]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.id] # source bucket account
      variable = "aws:SourceAccount"
    }
    condition {
      test     = "ArnLike"
      values   = [module.inventory_source_bucket.s3_bucket_arn] # source bucket arn
      variable = "aws:SourceARN"
    }
  }
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

    daily = {
      included_object_versions = "Current"
      destination = {
        format = "CSV"
        encryption = {
          encryption_type = "sse_kms"
          kms_key_id      = aws_kms_key.objects.arn
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
