locals {
  bucket_name = "${var.bucket_name_prefix}--${var.availability_zone_id}--x-s3"
}

resource "aws_s3_directory_bucket" "this" {
  count = var.create ? 1 : 0

  bucket          = local.bucket_name
  data_redundancy = var.data_redundancy
  force_destroy   = var.force_destroy
  type            = var.type

  location {
    name = var.availability_zone_id
    type = var.location_type
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count = var.create && length(var.server_side_encryption_configuration) > 0 ? 1 : 0

  bucket = aws_s3_directory_bucket.this[0].bucket

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      sse_algorithm     = var.server_side_encryption_configuration.sse_algorithm
      kms_master_key_id = try(var.server_side_encryption_configuration.kms_master_key_id, null)
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = var.create && length(var.lifecycle_rules) > 0 ? 1 : 0

  bucket = aws_s3_directory_bucket.this[0].bucket

  dynamic "rule" {
    for_each = var.lifecycle_rules

    content {
      id     = try(rule.value.id, rule.key)
      status = try(rule.value.enabled ? "Enabled" : "Disabled", tobool(rule.value.status) ? "Enabled" : "Disabled", title(lower(rule.value.status)))

      # Max 1 block - abort_incomplete_multipart_upload
      dynamic "abort_incomplete_multipart_upload" {
        for_each = try([rule.value.abort_incomplete_multipart_upload_days], [])

        content {
          days_after_initiation = try(rule.value.abort_incomplete_multipart_upload_days, null)
        }
      }

      # Max 1 block - expiration
      dynamic "expiration" {
        for_each = try(flatten([rule.value.expiration]), [])

        content {
          days = try(expiration.value.days, null)
        }
      }

      # Max 1 block - filter - with one key argument or a single tag
      dynamic "filter" {
        for_each = [for v in try(flatten([rule.value.filter]), []) : v if max(length(keys(v))) == 1]

        content {
          object_size_greater_than = try(filter.value.object_size_greater_than, null)
          object_size_less_than    = try(filter.value.object_size_less_than, null)
          prefix                   = try(filter.value.prefix, null)
        }
      }

      # Max 1 block - filter - with more than one key arguments or multiple tags
      dynamic "filter" {
        for_each = [for v in try(flatten([rule.value.filter]), []) : v if max(length(keys(v))) > 1]

        content {
          and {
            object_size_greater_than = try(filter.value.object_size_greater_than, null)
            object_size_less_than    = try(filter.value.object_size_less_than, null)
            prefix                   = try(filter.value.prefix, null)
          }
        }
      }
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  count = var.create && var.create_bucket_policy ? 1 : 0

  bucket = aws_s3_directory_bucket.this[0].bucket
  policy = data.aws_iam_policy_document.this[0].json
}

data "aws_iam_policy_document" "this" {
  count = var.create && var.create_bucket_policy ? 1 : 0

  source_policy_documents   = var.source_policy_documents
  override_policy_documents = var.override_policy_documents

  dynamic "statement" {
    for_each = var.policy_statements

    content {
      sid           = try(statement.value.sid, null)
      actions       = try(statement.value.actions, null)
      not_actions   = try(statement.value.not_actions, null)
      effect        = try(statement.value.effect, null)
      resources     = try(statement.value.resources, [aws_s3_directory_bucket.this[0].arn])
      not_resources = try(statement.value.not_resources, null)

      dynamic "principals" {
        for_each = try(statement.value.principals, [])

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = try(statement.value.not_principals, [])

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = try(statement.value.conditions, [])

        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }
}
