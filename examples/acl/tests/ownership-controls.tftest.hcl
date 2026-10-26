mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Deny\",\"Principal\":\"*\",\"Action\":\"s3:*\",\"Resource\":\"arn:aws:s3:::example-acl\",\"Condition\":{\"Bool\":{\"aws:SecureTransport\":\"false\"}}}]}"
    }
  }
}

run "existing_example_without_policy" {
  command = apply

  assert {
    condition     = module.acl_canned.s3_bucket_policy == null
    error_message = "The example must start without a bucket policy."
  }
}

run "enable_example_policy" {
  command = apply

  variables {
    attach_deny_insecure_transport_policy = true
  }

  assert {
    condition     = module.acl_canned.s3_bucket_policy != null
    error_message = "The example's policy toggle must attach the bucket policy."
  }
}

run "disable_example_policy" {
  command = apply

  assert {
    condition     = module.acl_canned.s3_bucket_policy == null
    error_message = "Disabling the example's policy toggle must remove the bucket policy."
  }
}
