resource "aws_s3tables_table_bucket" "this" {
  count = var.create ? 1 : 0

  region = var.region

  name                      = var.table_bucket_name
  encryption_configuration  = var.encryption_configuration
  maintenance_configuration = var.maintenance_configuration

  tags = var.tags
}

resource "aws_s3tables_table_bucket_policy" "this" {
  count = var.create && var.create_table_bucket_policy ? 1 : 0

  region = var.region

  resource_policy  = var.table_bucket_policy != null ? var.table_bucket_policy : data.aws_iam_policy_document.table_bucket_policy[0].json
  table_bucket_arn = aws_s3tables_table_bucket.this[0].arn
}

data "aws_iam_policy_document" "table_bucket_policy" {
  count = var.create && var.create_table_bucket_policy && var.table_bucket_policy == null ? 1 : 0

  source_policy_documents   = var.table_bucket_source_policy_documents
  override_policy_documents = var.table_bucket_override_policy_documents

  dynamic "statement" {
    for_each = var.table_bucket_policy_statements

    content {
      sid           = statement.value.sid
      actions       = statement.value.actions
      not_actions   = statement.value.not_actions
      effect        = statement.value.effect
      resources     = statement.value.resources != null ? statement.value.resources : ["${aws_s3tables_table_bucket.this[0].arn}/table/*"]
      not_resources = statement.value.not_resources

      dynamic "principals" {
        for_each = coalesce(statement.value.principals, [])

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = coalesce(statement.value.not_principals, [])

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = coalesce(statement.value.conditions, [])

        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }
}

resource "aws_s3tables_table" "this" {
  for_each = { for k, v in var.tables : k => v if var.create }

  region = var.region

  format                    = each.value.format
  name                      = coalesce(each.value.table_name, each.key)
  namespace                 = each.value.namespace
  table_bucket_arn          = aws_s3tables_table_bucket.this[0].arn
  encryption_configuration  = each.value.encryption_configuration
  maintenance_configuration = each.value.maintenance_configuration
  tags                      = merge(var.tags, each.value.tags)

  dynamic "metadata" {
    for_each = each.value.metadata != null ? [each.value.metadata] : []
    content {

      dynamic "iceberg" {
        for_each = metadata.value.iceberg != null ? [metadata.value.iceberg] : []
        content {

          dynamic "schema" {
            for_each = iceberg.value.schema != null ? [iceberg.value.schema] : []
            content {

              dynamic "field" {
                for_each = schema.value.field
                content {

                  name     = coalesce(field.value.name, field.key)
                  type     = field.value.type
                  required = field.value.required
                }
              }
            }
          }
        }
      }
    }
  }
}

resource "aws_s3tables_table_policy" "this" {
  for_each = { for k, v in var.tables : k => v if var.create && v.create_table_policy }

  region = var.region

  name             = aws_s3tables_table.this[each.key].name
  namespace        = each.value.namespace
  resource_policy  = data.aws_iam_policy_document.table_policy[each.key].json
  table_bucket_arn = aws_s3tables_table_bucket.this[0].arn
}

data "aws_iam_policy_document" "table_policy" {
  for_each = { for k, v in var.tables : k => v.policy_statements if var.create && v.create_table_policy }

  dynamic "statement" {
    for_each = each.value

    content {
      sid         = statement.value.sid
      actions     = statement.value.actions
      not_actions = statement.value.not_actions
      effect      = statement.value.effect
      resources   = [aws_s3tables_table.this[each.key].arn]

      dynamic "principals" {
        for_each = coalesce(statement.value.principals, [])

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = coalesce(statement.value.not_principals, [])

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = coalesce(statement.value.conditions, [])

        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }
}
