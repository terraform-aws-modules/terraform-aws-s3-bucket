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

################################################################################
# Inventory Configurations
################################################################################

module "multi_inventory_configurations_bucket" {
  source = "../../"

  bucket_prefix = "${local.name}-"

  # For example only
  force_destroy = true

  attach_policy                       = true
  attach_inventory_destination_policy = true
  inventory_self_source_destination   = true

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


  tags = local.tags
}

module "inventory_destination_bucket" {
  source = "../../"

  bucket_prefix = "${local.name}-dst-"

  # For example only
  force_destroy                       = true
  attach_policy                       = true
  attach_inventory_destination_policy = true
  inventory_source_bucket_arn         = module.multi_inventory_configurations_bucket.s3_bucket_arn
  inventory_source_account_id         = data.aws_caller_identity.current.id

  tags = local.tags
}

################################################################################
# Analytics Configurations
################################################################################

module "analytics_configuration_bucket" {
  source = "../../"

  bucket_prefix = "${local.name}-"

  # For example only
  force_destroy = true

  attach_analytics_destination_policy = true
  attach_policy                       = true
  analytics_self_source_destination   = true

  versioning = {
    status     = true
    mfa_delete = false
  }

  analytics_configuration = {

    # No exporting
    prefix_documents = {
      filter = {
        prefix = "documents/"
      }
    }

    # Same source and destination bucket
    tags = {
      filter = {
        tags = {
          production = "true"
        }
      }
      storage_class_analysis = {
        output_schema_version = "V_1"
      }
    }

    # Different destination bucket
    all = {
      storage_class_analysis = {
        destination_bucket_arn = module.analytics_destination_bucket.s3_bucket_arn
        prefix                 = "analytics"
      }
    }

    # Different destination shared with inventory destination
    example = {
      storage_class_analysis = {
        destination_bucket_arn = module.analytics_and_inventory_destination_bucket.s3_bucket_arn
      }
    }
  }


  tags = local.tags
}

module "analytics_destination_bucket" {
  source = "../../"

  bucket_prefix = "${local.name}-ana-dst-"

  # For example only
  force_destroy                       = true
  attach_policy                       = true
  attach_analytics_destination_policy = true
  analytics_source_bucket_arn         = module.analytics_configuration_bucket.s3_bucket_arn
  analytics_source_account_id         = data.aws_caller_identity.current.id

  tags = local.tags
}

# Inventory configuration for shared destination example
module "inventory_source_bucket" {
  source = "../.."

  bucket_prefix = "${local.name}-src-"

  # For example only
  force_destroy = true

  inventory_configuration = {
    destination_other = {
      included_object_versions = "All"
      destination = {
        bucket_arn = module.analytics_and_inventory_destination_bucket.s3_bucket_arn
        format     = "CSV"
        encryption = {
          encryption_type = "sse_s3"
        }
      }
      frequency       = "Daily"
      optional_fields = ["Size", "EncryptionStatus", "StorageClass", "ChecksumAlgorithm"]
    }
  }

  tags = local.tags
}

# Example of using the same destination bucket for analytics and inventory
module "analytics_and_inventory_destination_bucket" {
  source = "../../"

  bucket_prefix = "${local.name}-both-dst-"

  # For example only
  force_destroy = true
  attach_policy = true

  # Analytics bucket policy settings
  attach_analytics_destination_policy = true
  analytics_source_bucket_arn         = module.analytics_configuration_bucket.s3_bucket_arn
  analytics_source_account_id         = data.aws_caller_identity.current.id

  # Inventory bucket policy settings
  attach_inventory_destination_policy = true
  inventory_source_bucket_arn         = module.inventory_source_bucket.s3_bucket_arn
  inventory_source_account_id         = data.aws_caller_identity.current.id

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

# Inventory reports written to a KMS encrypted destination need the key to allow the S3
# service principal
# https://docs.aws.amazon.com/AmazonS3/latest/userguide/configure-inventory.html#configure-inventory-kms-key-policy
module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 4.0"

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

  tags = local.tags
}
