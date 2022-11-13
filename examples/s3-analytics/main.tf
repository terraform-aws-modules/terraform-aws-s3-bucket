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

    # Same source and destination buckets
    prefix_documents = {
      filter = {
        prefix = "documents/"
      }
    }

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

    all = {
      storage_class_analysis = {
        destination_bucket_arn = module.analytics_destination_bucket.s3_bucket_arn
        prefix                 = "analytics"
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
  attach_inventory_destination_policy = false
  attach_analytics_destination_policy = true
  analytics_source_bucket_arn         = module.analytics_configuration_bucket.s3_bucket_arn
  analytics_source_account_id         = data.aws_caller_identity.current.id
}
