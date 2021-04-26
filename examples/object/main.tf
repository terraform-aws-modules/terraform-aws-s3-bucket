provider "aws" {
  region = "eu-west-1"

  # Make it faster by skipping something
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}

module "object" {
  source = "../../modules/object"

  bucket = module.s3_bucket.s3_bucket_id
  key    = "${random_pet.this.id}-local"

  file_source = "README.md"
  #  content = file("README.md")
  #  content_base64 = filebase64("README.md")

  tags = {
    Sensitive = "not-really"
  }
}
module "object_complete" {
  source = "../../modules/object"

  bucket = module.s3_bucket.s3_bucket_id
  key    = "${random_pet.this.id}-complete"

  content = jsonencode({ data : "value" })

  acl           = "public-read"
  storage_class = "ONEZONE_IA"
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
  kms_key_id             = aws_kms_key.this.arn
}

module "object_locked" {
  source = "../../modules/object"

  bucket = module.s3_bucket_with_object_lock.s3_bucket_id
  key    = "${random_pet.this.id}-locked"

  content = "some-content-locked-by-governance"

  force_destroy = true

  object_lock_legal_hold_status = true # boolean or string ("ON" or "OFF")
  object_lock_mode              = "GOVERNANCE"
  object_lock_retain_until_date = formatdate("YYYY-MM-DD'T'hh:00:00Z", timeadd(timestamp(), "1h")) # some time in the future
}

##################
# Extra resources
##################
resource "random_pet" "this" {
  length = 2
}

resource "aws_kms_key" "this" {
  description             = "KMS key for S3 object"
  deletion_window_in_days = 7
}

#############
# S3 buckets
#############
module "s3_bucket" {
  source = "../../"

  bucket        = random_pet.this.id
  force_destroy = true
}

module "s3_bucket_with_object_lock" {
  source = "../../"

  bucket        = "${random_pet.this.id}-with-object-lock"
  force_destroy = true

  object_lock_configuration = {
    object_lock_enabled = "Enabled"
  }
}
