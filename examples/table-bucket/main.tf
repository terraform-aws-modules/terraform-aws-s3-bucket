provider "aws" {
  region = "eu-west-1"

  # Make it faster by skipping something
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
}

locals {
  bucket_name = "s3-table-bucket-${random_pet.this.id}"
}

data "aws_caller_identity" "this" {}

data "aws_region" "this" {}

module "table_bucket" {
  source = "../../modules/table-bucket"

  table_bucket_name = local.bucket_name

  encryption_configuration = {
    kms_key_arn   = module.kms.key_arn
    sse_algorithm = "aws:kms"
  }

  maintenance_configuration = {
    iceberg_unreferenced_file_removal = {
      status = "enabled"

      settings = {
        non_current_days  = 7
        unreferenced_days = 3
      }
    }
  }

  create_table_bucket_policy = true
  table_bucket_policy_statements = [
    {
      effect = "Allow"
      principals = [{
        type        = "AWS"
        identifiers = [data.aws_caller_identity.this.account_id]
      }]
      actions = [
        "s3tables:GetTableData",
        "s3tables:GetTableMetadataLocation"
      ]
    }
  ]

  tables = {
    table1 = {
      format    = "ICEBERG"
      namespace = aws_s3tables_namespace.namespace.namespace

      encryption_configuration = {
        kms_key_arn   = module.kms.key_arn
        sse_algorithm = "aws:kms"
      }

      maintenance_configuration = {
        iceberg_compaction = {
          status = "enabled"
          settings = {
            target_file_size_mb = 64
          }
        }
        iceberg_snapshot_management = {
          status = "enabled"
          settings = {
            max_snapshot_age_hours = 40
            min_snapshots_to_keep  = 3
          }
        }
      }

      create_table_policy = true
      policy_statements = [
        {
          sid    = "DeleteTable"
          effect = "Allow"
          principals = [{
            type        = "AWS"
            identifiers = [data.aws_caller_identity.this.account_id]
          }]
          actions = [
            "s3tables:DeleteTable",
            "s3tables:UpdateTableMetadataLocation",
            "s3tables:PutTableData",
            "s3tables:GetTableMetadataLocation"
          ]
        }
      ]
    }
    table2 = {
      format    = "ICEBERG"
      name      = "table2"
      namespace = aws_s3tables_namespace.namespace.namespace
    }
    table3 = {
      format    = "ICEBERG"
      namespace = aws_s3tables_namespace.namespace.namespace

      metadata = {
        iceberg = {
          schema = {
            field = {
              created_at = {
                name     = "created_at"
                type     = "timestamp"
                required = false
              }
              price = {
                type     = "decimal(10,2)"
                required = false
              }
            }
          }
        }
      }
    }
  }
}

resource "random_pet" "this" {
  length = 2
}

resource "aws_s3tables_namespace" "namespace" {
  namespace        = "example_namespace"
  table_bucket_arn = module.table_bucket.s3_table_bucket_arn
}

module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 3.0"

  description             = "Key example for s3 table buckets"
  deletion_window_in_days = 7

  # https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-tables-kms-permissions.html
  key_statements = [
    {
      sid = "s3TablesMaintenancePolicy"
      actions = [
        "kms:GenerateDataKey",
        "kms:Decrypt"
      ]
      resources = ["*"]

      principals = [
        {
          type        = "Service"
          identifiers = ["maintenance.s3tables.amazonaws.com"]
        }
      ]

      conditions = [
        {
          test     = "StringEquals"
          variable = "aws:SourceAccount"
          values = [
            data.aws_caller_identity.this.id,
          ]
        },
        {
          test     = "StringLike"
          variable = "kms:EncryptionContext:aws:s3:arn"
          values = [
            "arn:aws:s3tables:${data.aws_region.this.region}:${data.aws_caller_identity.this.account_id}:bucket/${local.bucket_name}/table/*"
          ]
        }
      ]
    }
  ]
}
