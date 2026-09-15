provider "aws" {
  region = local.region
}

locals {
  region      = "eu-west-1"
  name        = "ex-${basename(path.cwd)}"
  bucket_name = "${local.name}-s3-table-bucket"

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-s3-bucket"
  }
}

data "aws_caller_identity" "this" {}

################################################################################
# Table Bucket
################################################################################

module "table_bucket" {
  source = "../../modules/table-bucket"

  region = local.region

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

  tags = local.tags

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

      tags = {
        table_name = "table1"
      }
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

# A caller supplying a complete policy document, rather than having the module build one from
# statements. table_bucket_policy takes precedence; the source and override document lists are
# merged into a generated policy when it does not.
module "caller_supplied_policy" {
  source = "../../modules/table-bucket"

  region = local.region

  table_bucket_name          = "${local.name}-policy"
  create_table_bucket_policy = true
  table_bucket_policy        = data.aws_iam_policy_document.table_bucket.json

  tags = local.tags
}

module "merged_policy_documents" {
  source = "../../modules/table-bucket"

  region = local.region

  table_bucket_name                      = "${local.name}-merged"
  create_table_bucket_policy             = true
  table_bucket_source_policy_documents   = [data.aws_iam_policy_document.table_bucket.json]
  table_bucket_override_policy_documents = [data.aws_iam_policy_document.table_bucket_override.json]

  tags = local.tags
}

################################################################################
# Disabled
################################################################################

module "disabled" {
  source = "../../modules/table-bucket"

  create = false
}

################################################################################
# Supporting Resources
################################################################################

resource "aws_s3tables_namespace" "namespace" {
  namespace        = "example_namespace"
  table_bucket_arn = module.table_bucket.s3_table_bucket_arn
}

module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 4.0"

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
            "arn:aws:s3tables:${local.region}:${data.aws_caller_identity.this.account_id}:bucket/${local.bucket_name}/table/*"
          ]
        }
      ]
    }
  ]


  tags = local.tags
}

data "aws_iam_policy_document" "table_bucket" {
  statement {
    sid       = "AllowAccountRead"
    actions   = ["s3tables:GetTableData"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.this.account_id]
    }
  }
}

data "aws_iam_policy_document" "table_bucket_override" {
  statement {
    sid       = "AllowAccountRead"
    actions   = ["s3tables:GetTableData", "s3tables:GetTableMetadataLocation"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.this.account_id]
    }
  }
}
