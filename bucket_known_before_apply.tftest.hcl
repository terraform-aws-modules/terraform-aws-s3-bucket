provider "aws" {
  region = "eu-west-1"
}

variables {
  bucket            = "known-value"
  create_bucket_acl = true
  acl               = "private"
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = "aws/s3"
      }
      bucket_key_enabled = true
    }
  }
}

run "bucket_value_known_before_apply" {
  command = plan

  assert {
    condition     = aws_s3_bucket_acl.this[0].bucket == var.bucket
    error_message = "Bucket value did not match provided bucket name."
  }

  assert {
    condition     = aws_s3_bucket_server_side_encryption_configuration.this[0].bucket == var.bucket
    error_message = "Bucket value did not match provided bucket name."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this[0].bucket == var.bucket
    error_message = "Bucket value did not match provided bucket name."
  }


}