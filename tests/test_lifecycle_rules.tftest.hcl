# Default AWS provider configuration
mock_provider "aws" {
}

# Default required test variables
variables {
  bucket_name             = "test-bucket"
  kms_key_arn             = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  readonly_iam_role_arns  = []
  readwrite_iam_role_arns = []
  backup_enabled          = false
}

# Test 1
run "verify_valid_lifecycle_rules" {
  command = plan

  variables {
    lifecycle_rules = [
      {
        id      = "log"
        enabled = true
        filter = {
          tags = {
            some    = "value"
            another = "value2"
          }
        }
        transition = [
          {
            days          = 30
            storage_class = "ONEZONE_IA"
          },
          {
            days          = 60
            storage_class = "GLACIER"
          }
        ]
      },
      {
        id                                     = "log1"
        enabled                                = true
        abort_incomplete_multipart_upload_days = 7
        noncurrent_version_transition = [
          {
            days          = 30
            storage_class = "STANDARD_IA"
          }
        ]
        noncurrent_version_expiration = {
          days = 300
        }
      },
      {
        id     = "expire_all_objects"
        status = "Enabled"
        expiration = {
          days = 7
        }
        noncurrent_version_expiration = {
          noncurrent_days = 3
        }
        abort_incomplete_multipart_upload_days = 1
      }
    ]
  }

  assert {
    condition     = length(var.lifecycle_rules) == 3
    error_message = "Expected 3 lifecycle rules"
  }

  assert {
    condition = alltrue([
      for rule in var.lifecycle_rules : contains(keys(rule), "id")
    ])
    error_message = "All rules must have an id"
  }

  assert {
    condition = alltrue([
      for rule in var.lifecycle_rules :
      anytrue([contains(keys(rule), "enabled"), contains(keys(rule), "status")])
    ])
    error_message = "All rules must have either enabled or status field"
  }

  assert {
    condition = alltrue([
      for rule in var.lifecycle_rules :
      anytrue([
        !contains(keys(rule), "abort_incomplete_multipart_upload_days"),
        can(tonumber(rule.abort_incomplete_multipart_upload_days))
      ])
    ])
    error_message = "abort_incomplete_multipart_upload_days must be a number"
  }
}

# Test 2
run "fail_invalid_lifecycle_rules" {
  command = plan

  variables {
    lifecycle_rules = [
      {
        id      = "log1"
        enabled = true
        abort_incomplete_multipart_upload = {
          days_after_initiation = "1"
        }
        noncurrent_version_transition = [
          {
            days          = 30
            storage_class = "STANDARD_IA"
          }
        ]
        noncurrent_version_expiration = {
          days = 300
        }
      }
    ]
  }

  expect_failures = [
    var.lifecycle_rules
  ]

  assert {
    condition = !alltrue([
      for rule in var.lifecycle_rules : (
        contains(keys(rule), "id") &&
        (contains(keys(rule), "enabled") || contains(keys(rule), "status")) &&
        alltrue([
          for key in keys(rule) : contains([
            "id",
            "enabled",
            "status",
            "filter",
            "abort_incomplete_multipart_upload_days",
            "expiration",
            "transition",
            "noncurrent_version_expiration",
            "noncurrent_version_transition"
          ], key)
        ])
      )
    ])
    error_message = "Each lifecycle rule must contain 'id' and either 'enabled' or 'status', and may contain: 'filter', 'abort_incomplete_multipart_upload_days', 'expiration', 'transition', 'noncurrent_version_expiration', or 'noncurrent_version_transition'."
  }
}
