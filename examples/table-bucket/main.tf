provider "aws" {
  region = "us-east-1" # CloudFront expects ACM resources in us-east-1 region only

  # Make it faster by skipping something
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
}

locals {
  bucket_name = "s3-table-bucket-${random_pet.this.id}"
}

data "aws_caller_identity" "this" {}

resource "random_pet" "this" {
  length = 2
}

module "table_bucket" {
  source = "../../modules/table-bucket"

  table_bucket_name = local.bucket_name

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
      s3_paths = ["table/*"]
    }
  ]


  tables = {
    table1 = {
      format    = "ICEBERG"
      namespace = aws_s3tables_namespace.namespace.namespace

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
    }
  }
}

resource "aws_s3tables_namespace" "namespace" {
  namespace        = "example_namespace"
  table_bucket_arn = module.table_bucket.s3_table_bucket_arn
}
