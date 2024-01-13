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

module "analytics_configuration_bucket" {
  source = "../../"

  bucket = local.bucket_name

  force_destroy = true

  attach_analytics_destination_policy = true
  attach_policy                       = true
  analytics_self_source_destination   = true
  acl                                 = "private" # "acl" conflicts with "grant" and "owner"

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
}

resource "random_pet" "this" {
  length = 2
}

module "analytics_destination_bucket" {
  source = "../../"

  bucket                              = "analytics-destination-${random_pet.this.id}"
  acl                                 = "private" # "acl" conflicts with "grant" and "owner"
  force_destroy                       = true
  attach_policy                       = true
  attach_analytics_destination_policy = true
  analytics_source_bucket_arn         = module.analytics_configuration_bucket.s3_bucket_arn
  analytics_source_account_id         = data.aws_caller_identity.current.id
}

# Inventory configuration for shared destination example
module "inventory_source_bucket" {
  source = "../.."

  bucket = "inventory-source-${random_pet.this.id}"

  force_destroy = true
  acl           = "private" # "acl" conflicts with "grant" and "owner"

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
}

# Example of using the same destination bucket for analytics and inventory
module "analytics_and_inventory_destination_bucket" {
  source = "../../"

  bucket        = "analytics-and-inventory-destination-${random_pet.this.id}"
  acl           = "private" # "acl" conflicts with "grant" and "owner"
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
}
