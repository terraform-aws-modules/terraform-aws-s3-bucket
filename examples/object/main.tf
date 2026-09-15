provider "aws" {
  region = local.region


  default_tags {
    tags = {
      Example = "object"
    }
  }
}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "eu-west-1"

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-s3-bucket"
  }
}

################################################################################
# Objects
################################################################################

module "object" {
  source = "../../modules/object"

  region = local.region

  bucket = module.s3_bucket.s3_bucket_id
  key    = "${local.name}-local"

  # Triggers an update when the file content changes, without relying on etag, which is not a
  # content hash for multipart or SSE-KMS objects
  source_hash = filemd5("${path.module}/versions.tf")

  file_source = "README.md"
  #  content = file("README.md")
  #  content_base64 = filebase64("README.md")

  tags = {
    Sensitive = "not-really"
  }
}

# content_base64 is mutually exclusive with content, so it gets its own object
module "object_base64" {
  source = "../../modules/object"

  bucket = module.s3_bucket.s3_bucket_id
  key    = "${local.name}-base64"

  content_base64 = base64encode("some-base64-encoded-content")

  # etag is the MD5 of the object content and triggers an update when it changes. Use
  # source_hash instead where the etag is not a content hash, such as multipart or SSE-KMS
  etag = md5("some-base64-encoded-content")

  # For example only
  force_destroy = true

  tags = local.tags
}

module "object_complete" {
  source = "../../modules/object"

  bucket = module.s3_bucket.s3_bucket_id
  key    = "${local.name}-complete"

  bucket_key_enabled = true

  content = jsonencode({ data : "value" })

  storage_class = "ONEZONE_IA"

  # For example only
  force_destroy = true

  cache_control       = "public; max-age=1200"
  content_disposition = "attachment; filename=\"invoice.pdf\""
  content_encoding    = "gzip"
  content_language    = "en-US"
  content_type        = "application/json"

  website_redirect = "https://www.google.com/"
  metadata = {
    key         = "value1"
    another-key = "value2"
  }

  server_side_encryption = "aws:kms"
  kms_key_id             = module.kms.key_arn

  tags = local.tags
}

module "object_locked" {
  source = "../../modules/object"

  bucket = module.s3_bucket_with_object_lock.s3_bucket_id
  key    = "${local.name}-locked"

  content = "some-content-locked-by-governance"

  # For example only
  force_destroy = true

  object_lock_legal_hold_status = true # boolean or string ("ON" or "OFF")
  object_lock_mode              = "GOVERNANCE"
  object_lock_retain_until_date = formatdate("YYYY-MM-DD'T'hh:00:00Z", timeadd(timestamp(), "1h")) # some time in the future

  tags = local.tags
}

module "object_with_override_default_tags" {
  source = "../../modules/object"

  bucket = module.s3_bucket.s3_bucket_id
  key    = "${local.name}-local-override-default-tags"

  override_default_tags = true

  file_source = "README.md"

  tags = {
    Override = "true"
  }
}

################################################################################
# Disabled
################################################################################

module "disabled" {
  source = "../../modules/object"

  create = false
}

################################################################################
# Supporting Resources
################################################################################

module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 4.0"

  description             = "KMS key for S3 object"
  deletion_window_in_days = 7

  tags = local.tags
}

module "s3_bucket" {
  source = "../../"

  bucket_prefix = "${local.name}-"

  # For example only
  force_destroy = true

  tags = local.tags
}

module "s3_bucket_with_object_lock" {
  source = "../../"

  bucket_prefix = "${local.name}-lock-"

  # For example only
  force_destroy = true

  object_lock_enabled = true
  object_lock_configuration = {
    rule = {
      default_retention = {
        mode = "GOVERNANCE"
        days = 1
      }
    }
  }

  tags = local.tags
}
