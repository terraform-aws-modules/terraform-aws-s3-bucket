# Run with Terraform >= 1.7. Mock applies seed state; offline plans use the real
# provider schema so a computed policy ID remains unknown when the policy is new.
mock_provider "aws" {
  mock_resource "aws_s3_bucket" {
    defaults = {
      id  = "example-ownership-controls"
      arn = "arn:aws:s3:::example-ownership-controls"
    }
  }

  mock_resource "aws_s3_bucket_ownership_controls" {
    defaults = {
      id = "example-ownership-controls"
    }
  }

  mock_resource "aws_s3_bucket_policy" {
    defaults = {
      id = "example-ownership-controls"
    }
  }

  mock_resource "aws_s3_bucket_acl" {
    defaults = {
      id = "example-ownership-controls,private"
    }
  }

  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Deny\",\"Principal\":\"*\",\"Action\":\"s3:*\",\"Resource\":\"arn:aws:s3:::example-ownership-controls\",\"Condition\":{\"Bool\":{\"aws:SecureTransport\":\"false\"}}}]}"
    }
  }
}

provider "aws" {
  alias = "offline"

  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

override_data {
  target = data.aws_caller_identity.current[0]
  values = {
    account_id = "123456789012"
  }
}

override_data {
  target = data.aws_canonical_user_id.this[0]
  values = {
    id = "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
  }
}

override_data {
  target = data.aws_region.current[0]
  values = {
    region = "us-east-1"
  }
}

override_data {
  target = data.aws_partition.current[0]
  values = {
    partition = "aws"
  }
}

variables {
  bucket                   = "example-ownership-controls"
  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"
}

run "existing_bucket_without_policy" {
  command = apply
}

run "add_first_policy_without_replacing_ownership_controls" {
  command = plan

  providers = {
    aws = aws.offline
  }

  plan_options {
    refresh = false
  }

  variables {
    attach_deny_insecure_transport_policy = true
  }

  assert {
    condition     = aws_s3_bucket_ownership_controls.this[0].id == var.bucket
    error_message = "Adding the first bucket policy must preserve the existing ownership controls."
  }
}

run "existing_bucket_with_policy" {
  command = apply

  variables {
    attach_deny_insecure_transport_policy = true
  }
}

run "remove_last_policy_without_replacing_ownership_controls" {
  command = plan

  providers = {
    aws = aws.offline
  }

  plan_options {
    refresh = false
  }

  assert {
    condition     = aws_s3_bucket_ownership_controls.this[0].id == var.bucket
    error_message = "Removing the last bucket policy must preserve the existing ownership controls."
  }
}

run "existing_acl_bucket_without_policy" {
  command = apply

  variables {
    object_ownership = "BucketOwnerPreferred"
    acl              = "private"
  }
}

run "add_first_policy_without_replacing_acl_ownership_controls" {
  command = plan

  providers = {
    aws = aws.offline
  }

  plan_options {
    refresh = false
  }

  variables {
    object_ownership                      = "BucketOwnerPreferred"
    acl                                   = "private"
    attach_deny_insecure_transport_policy = true
  }

  assert {
    condition     = aws_s3_bucket_ownership_controls.this[0].id == var.bucket
    error_message = "Adding the first bucket policy must preserve ACL-enabled ownership controls."
  }

  assert {
    condition     = aws_s3_bucket_acl.this[0].id == "${var.bucket},private"
    error_message = "Adding the first bucket policy must preserve the existing ACL."
  }
}

run "existing_acl_bucket_with_policy" {
  command = apply

  variables {
    object_ownership                      = "BucketOwnerPreferred"
    acl                                   = "private"
    attach_deny_insecure_transport_policy = true
  }
}

run "remove_last_policy_without_replacing_acl_ownership_controls" {
  command = plan

  providers = {
    aws = aws.offline
  }

  plan_options {
    refresh = false
  }

  variables {
    object_ownership = "BucketOwnerPreferred"
    acl              = "private"
  }

  assert {
    condition     = aws_s3_bucket_ownership_controls.this[0].id == var.bucket
    error_message = "Removing the last bucket policy must preserve ACL-enabled ownership controls."
  }

  assert {
    condition     = aws_s3_bucket_acl.this[0].id == "${var.bucket},private"
    error_message = "Removing the last bucket policy must preserve the existing ACL."
  }
}
