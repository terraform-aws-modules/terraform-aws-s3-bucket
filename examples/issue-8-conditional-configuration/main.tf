resource "random_pet" "this" {
  length = 2
}

module "s3_bucket" {
  source = "../../"

  bucket        = "s3-bucket-${random_pet.this.id}"
  acl           = "private"
  force_destroy = true

  versioning = false ? {
    enabled = true
  } : {}

  website = false ? {
    index_document = "index.html"
    error_document = "error.html"
    routing_rules = jsonencode([{
      Condition : {
        KeyPrefixEquals : "docs/"
      },
      Redirect : {
        ReplaceKeyPrefixWith : "documents/"
      }
    }])
  } : {}

  logging = false ? {
    target_bucket = "some-bucket"
    target_prefix = "log/"
  } : {}

  cors_rule = false ? {
    allowed_methods = ["PUT", "POST"]
    allowed_origins = ["https://modules.tf", "https://terraform-aws-modules.modules.tf"]
    allowed_headers = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  } : null

  server_side_encryption_configuration = false ? {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "aws:kms"
      }
    }
  } : {}

  object_lock_configuration = false ? {
    object_lock_enabled = "Enabled"
    rule = {
      default_retention = {
        mode  = "COMPLIANCE"
        years = 5
      }
    }
  } : null
}
