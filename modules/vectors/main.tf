################################################################################
# Amazon S3 Vectors Vector Bucket
################################################################################

resource "aws_s3vectors_vector_bucket" "this" {
  count = var.create ? 1 : 0

  vector_bucket_name = var.vector_bucket_name
  force_destroy      = var.force_destroy
  region             = var.region
  tags               = var.tags

  dynamic "encryption_configuration" {
    for_each = var.encryption_configuration != null ? [var.encryption_configuration] : []

    content {
      sse_type    = encryption_configuration.value.sse_type
      kms_key_arn = encryption_configuration.value.kms_key_arn
    }
  }
}

################################################################################
# Amazon S3 Vectors Vector Bucket Policy
################################################################################

resource "aws_s3vectors_vector_bucket_policy" "this" {
  count = var.create && var.create_policy ? 1 : 0

  vector_bucket_arn = aws_s3vectors_vector_bucket.this[0].vector_bucket_arn
  policy            = var.policy
  region            = var.region
}

################################################################################
# Amazon S3 Vectors Index
################################################################################

resource "aws_s3vectors_index" "this" {
  for_each = { for k, v in var.indexes : k => v if var.create }

  index_name         = each.value.index_name
  vector_bucket_name = aws_s3vectors_vector_bucket.this[0].vector_bucket_name

  data_type       = each.value.data_type
  dimension       = each.value.dimension
  distance_metric = each.value.distance_metric
  region          = var.region
  tags            = merge(var.tags, each.value.tags)

  dynamic "encryption_configuration" {
    for_each = each.value.encryption_configuration != null ? [each.value.encryption_configuration] : []

    content {
      sse_type    = encryption_configuration.value.sse_type
      kms_key_arn = encryption_configuration.value.kms_key_arn
    }
  }

  dynamic "metadata_configuration" {
    for_each = each.value.metadata_configuration != null ? [each.value.metadata_configuration] : []

    content {
      non_filterable_metadata_keys = metadata_configuration.value.non_filterable_metadata_keys
    }
  }
}
