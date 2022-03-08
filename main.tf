locals {
  attach_policy = var.attach_require_latest_tls_policy || var.attach_elb_log_delivery_policy || var.attach_lb_log_delivery_policy || var.attach_deny_insecure_transport_policy || var.attach_policy
}

resource "aws_s3_bucket" "this" {
  bucket        = var.bucket
  bucket_prefix = var.bucket_prefix

  dynamic "object_lock_configuration" {
    for_each = length(keys(var.object_lock_configuration)) == 0 ? [] : [{}]
    content {
      object_lock_enabled = "Enabled"
    }
  }

  tags          = var.tags
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_policy" "this" {
  count = local.attach_policy ? 1 : 0

  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.combined[0].json
}

data "aws_iam_policy_document" "combined" {
  count = local.attach_policy ? 1 : 0

  source_policy_documents = compact([
    var.attach_elb_log_delivery_policy ? data.aws_iam_policy_document.elb_log_delivery[0].json : "",
    var.attach_lb_log_delivery_policy ? data.aws_iam_policy_document.lb_log_delivery[0].json : "",
    var.attach_require_latest_tls_policy ? data.aws_iam_policy_document.require_latest_tls[0].json : "",
    var.attach_deny_insecure_transport_policy ? data.aws_iam_policy_document.deny_insecure_transport[0].json : "",
    var.attach_policy ? var.policy : ""
  ])
}

# AWS Load Balancer access log delivery policy
data "aws_elb_service_account" "this" {
  count = var.attach_elb_log_delivery_policy ? 1 : 0
}

data "aws_iam_policy_document" "elb_log_delivery" {
  count = var.attach_elb_log_delivery_policy ? 1 : 0

  statement {
    sid = ""

    principals {
      type        = "AWS"
      identifiers = data.aws_elb_service_account.this.*.arn
    }

    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*",
    ]
  }
}

# ALB/NLB

data "aws_iam_policy_document" "lb_log_delivery" {
  count = var.attach_lb_log_delivery_policy ? 1 : 0

  statement {
    sid = "AWSLogDeliveryWrite"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    sid = "AWSLogDeliveryAclCheck"

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",
    ]

    resources = [
      aws_s3_bucket.this.arn,
    ]

  }
}

data "aws_iam_policy_document" "deny_insecure_transport" {
  count = var.attach_deny_insecure_transport_policy ? 1 : 0

  statement {
    sid    = "denyInsecureTransport"
    effect = "Deny"

    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        "false"
      ]
    }
  }
}

data "aws_iam_policy_document" "require_latest_tls" {
  count = var.attach_require_latest_tls_policy ? 1 : 0

  statement {
    sid    = "denyOutdatedTLS"
    effect = "Deny"

    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "NumericLessThan"
      variable = "s3:TlsVersion"
      values = [
        "1.2"
      ]
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  count = var.attach_public_policy ? 1 : 0

  # Chain resources (s3_bucket -> s3_bucket_policy -> s3_bucket_public_access_block)
  # to prevent "A conflicting conditional operation is currently in progress against this resource."
  # Ref: https://github.com/hashicorp/terraform-provider-aws/issues/7628

  bucket = local.attach_policy ? aws_s3_bucket_policy.this[0].id : aws_s3_bucket.this.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_ownership_controls" "this" {
  count = var.control_object_ownership ? 1 : 0

  bucket = local.attach_policy ? aws_s3_bucket_policy.this[0].id : aws_s3_bucket.this.id

  rule {
    object_ownership = var.object_ownership
  }

  # This `depends_on` is to prevent "A conflicting conditional operation is currently in progress against this resource."
  depends_on = [
    aws_s3_bucket_policy.this,
    aws_s3_bucket_public_access_block.this,
    aws_s3_bucket.this
  ]
}

resource "aws_s3_bucket_accelerate_configuration" "this" {
  count  = var.acceleration_status != null ? 1 : 0
  bucket = aws_s3_bucket.this.id
  status = var.acceleration_status
}

resource "aws_s3_bucket_acl" "this" {
  count = var.acl == "" && length(keys(try(jsondecode(var.access_control_policy), var.access_control_policy))) == 0 ? 0 : 1

  bucket = aws_s3_bucket.this.id
  acl    = var.acl

  dynamic "access_control_policy" {
    for_each = length(try(jsondecode(var.access_control_policy), var.access_control_policy)) == 0 ? [] : [try(jsondecode(var.access_control_policy), var.access_control_policy)]

    content {
      dynamic "grant" {
        for_each = lookup(access_control_policy.value, "grants")

        content {
          grantee {
            email_address = lookup(grant.value, "email_address", null)
            id            = lookup(grant.value, "id", null)
            type          = lookup(grant.value, "type")
            uri           = lookup(grant.value, "uri", null)
          }

          permission = lookup(grant.value, "permission")
        }
      }

      owner {
        id           = lookup(access_control_policy.value, "owner_id", null)
        display_name = lookup(access_control_policy.value, "owner_name", null)
      }
    }
  }
}

resource "aws_s3_bucket_cors_configuration" "this" {
  count  = length(try(jsondecode(var.cors_rule), var.cors_rule)) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "cors_rule" {
    for_each = try(jsondecode(var.cors_rule), var.cors_rule)

    content {
      id              = lookup(cors_rule.value, "id", null)
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      allowed_headers = lookup(cors_rule.value, "allowed_headers", null)
      expose_headers  = lookup(cors_rule.value, "expose_headers", null)
      max_age_seconds = lookup(cors_rule.value, "max_age_seconds", null)
    }
  }
}


resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = length(try(jsondecode(var.lifecycle_rule), var.lifecycle_rule)) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = try(jsondecode(var.lifecycle_rule), var.lifecycle_rule)

    content {
      id     = lookup(rule.value, "id", null)
      status = lookup(rule.value, "enabled", true) ? "Enabled" : "Disabled"

      dynamic "abort_incomplete_multipart_upload" {
        for_each = lookup(rule.value, "abort_incomplete_multipart_upload_days", null) == null ? [] : [lookup(rule.value, "abort_incomplete_multipart_upload_days")]

        content {
          days_after_initiation = abort_incomplete_multipart_upload.value
        }
      }

      # Send empty map if `filter` is an empty map or absent entirely
      dynamic "filter" {
        for_each = length(keys(lookup(rule.value, "filter", {}))) == 0 ? [{}] : []

        content {}
      }

      dynamic "filter" {
        for_each = length(keys(lookup(rule.value, "filter", {}))) == 0 ? [] : [lookup(rule.value, "filter")]

        content {
          dynamic "and" {
            for_each = lookup(filter.value, "prefix", "") != "" && length(keys(lookup(filter.value, "tags", {}))) > 1 ? [{ prefix : lookup(filter.value, "prefix"), tags : lookup(filter.value, "tags") }] : []

            content {
              tags   = lookup(and.value, "tags")
              prefix = lookup(and.value, "prefix")
            }
          }

          dynamic "tag" {
            for_each = lookup(filter.value, "prefix", "") == "" && length(keys(lookup(filter.value, "tags", {}))) == 1 ? [element(lookup(filter.value, "tags"), 0)] : []

            content {
              key   = tag.key
              value = tag.value
            }
          }

          dynamic "prefix" {
            for_each = lookup(filter.value, "prefix", "") != "" && length(keys(lookup(filter.value, "tags", {}))) == 0 ? [lookup(filter.value, "prefix")] : []

            content {
              prefix = prefix.value
            }
          }
        }
      }


      # Max 1 block - expiration
      dynamic "expiration" {
        for_each = length(keys(lookup(rule.value, "expiration", {}))) == 0 ? [] : [lookup(rule, "expiration", {})]

        content {
          date                         = lookup(expiration.value, "date", null)
          days                         = lookup(expiration.value, "days", null)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
        }
      }

      # Several blocks - transition
      dynamic "transition" {
        for_each = lookup(rule.value, "transition", [])

        content {
          date          = lookup(transition.value, "date", null)
          days          = lookup(transition.value, "days", null)
          storage_class = transition.value.storage_class
        }
      }

      # Max 1 block - noncurrent_version_expiration
      dynamic "noncurrent_version_expiration" {
        for_each = length(keys(lookup(rule.value, "noncurrent_version_expiration", {}))) == 0 ? [] : [lookup(rule.value, "noncurrent_version_expiration", {})]

        content {
          newer_noncurrent_versions = lookup(noncurrent_version_expiration.value, "newer_noncurrent_versions", null)
          noncurrent_days           = lookup(noncurrent_version_expiration.value, "days", null)
        }
      }

      # Several blocks - noncurrent_version_transition
      dynamic "noncurrent_version_transition" {
        for_each = lookup(rule.value, "noncurrent_version_transition", [])

        content {
          newer_noncurrent_versions = lookup(noncurrent_version_transition.value, "newer_noncurrent_versions", null)
          noncurrent_days           = lookup(noncurrent_version_transition.value, "days", null)
          storage_class             = noncurrent_version_transition.value.storage_class
        }
      }
    }
  }
}

resource "aws_s3_bucket_logging" "this" {
  count = length(keys(var.logging)) == 0 ? 0 : 1

  bucket        = aws_s3_bucket.this.id
  target_bucket = lookup(var.logging, "target_bucket")
  target_prefix = lookup(var.logging, "target_prefix", null)
}

resource "aws_s3_bucket_object_lock_configuration" "this" {
  count  = length(keys(var.object_lock_configuration)) == 0 ? 0 : 1
  bucket = aws_s3_bucket.this.id

  object_lock_enabled = lookup(var.object_lock_configuration, "object_lock_enabled")


  dynamic "rule" {
    for_each = length(keys(lookup(var.object_lock_configuration, "rule", {}))) == 0 ? [] : [lookup(var.object_lock_configuration, "rule", {})]

    content {
      default_retention {
        mode  = lookup(lookup(rule.value, "default_retention", {}), "mode")
        days  = lookup(lookup(rule.value, "default_retention", {}), "days", null)
        years = lookup(lookup(rule.value, "default_retention", {}), "years", null)
      }
    }
  }
}

resource "aws_s3_bucket_replication_configuration" "this" {
  count = length(keys(var.replication_configuration)) == 0 ? 0 : 1

  bucket = aws_s3_bucket.this.id
  role   = lookup(var.replication_configuration, "role", null)

  dynamic "rule" {
    for_each = lookup(var.replication_configuration, "rules", [])

    content {
      id       = lookup(rule.value, "id", null)
      priority = lookup(rule.value, "priority", null)
      prefix   = lookup(rule.value, "prefix", null)
      status   = lookup(rule.value, "enabled", true) ? "Enabled" : "Disabled"

      dynamic "delete_marker_replication" {
        for_each = length(keys(lookup(rule.value, "delete_marker_replication", {}))) == 0 ? [] : [lookup(rule.value, "delete_marker_replication", {})]

        content {
          status = lookup(delete_marker_replication.value, "status", null)
        }
      }

      dynamic "destination" {
        for_each = length(keys(lookup(rule.value, "destination", {}))) == 0 ? [] : [lookup(rule.value, "destination", {})]

        content {
          bucket        = destination.value.bucket
          storage_class = lookup(destination.value, "storage_class", null)
          account       = lookup(destination.value, "account_id", null)

          dynamic "access_control_translation" {
            for_each = length(keys(lookup(destination.value, "access_control_translation", {}))) == 0 ? [] : [lookup(destination.value, "access_control_translation", {})]

            content {
              owner = access_control_translation.value.owner
            }
          }

          dynamic "encryption_configuration" {
            for_each = lookup(destination, "replica_kms_key_id", null) == null ? [] : [lookup(destination, "replica_kms_key_id")]

            content {
              replica_kms_key_id = encryption_configuration.value
            }
          }

          dynamic "replication_time" {
            for_each = length(keys(lookup(destination.value, "replication_time", {}))) == 0 ? [] : [lookup(destination.value, "replication_time", {})]

            content {
              status = replication_time.value.status
              time {
                minutes = replication_time.value.minutes
              }
            }
          }

          dynamic "metrics" {
            for_each = length(keys(lookup(destination.value, "metrics", {}))) == 0 ? [] : [lookup(destination.value, "metrics", {})]

            content {
              status = metrics.value.status

              event_threshold {
                minutes = metrics.value.minutes
              }
            }
          }
        }
      }

      dynamic "source_selection_criteria" {
        for_each = length(keys(lookup(rule.value, "source_selection_criteria", {}))) == 0 ? [] : [lookup(rule.value, "source_selection_criteria", {})]

        content {

          dynamic "sse_kms_encrypted_objects" {
            for_each = length(keys(lookup(source_selection_criteria.value, "sse_kms_encrypted_objects", {}))) == 0 ? [] : [lookup(source_selection_criteria.value, "sse_kms_encrypted_objects", {})]

            content {
              status = sse_kms_encrypted_objects.value
            }
          }

          dynamic "replica_modifications" {
            for_each = length(keys(lookup(source_selection_criteria.value, "replica_modifications", {}))) == 0 ? [] : [lookup(source_selection_criteria.value, "replica_modifications", {})]

            content {
              status = replica_modifications.value
            }
          }
        }
      }

      # Send empty map if `filter` is an empty map or absent entirely
      dynamic "filter" {
        for_each = length(keys(lookup(rule.value, "filter", {}))) == 0 ? [{}] : []

        content {}
      }

      # Send `filter` if it is present and has at least one field
      dynamic "filter" {
        for_each = length(keys(lookup(rule.value, "filter", {}))) != 0 ? [lookup(rule.value, "filter", {})] : []

        content {
          prefix = lookup(filter.value, "prefix", null)
          tags   = lookup(filter.value, "tags", null)
        }
      }

    }
  }
}

resource "aws_s3_bucket_request_payment_configuration" "this" {
  count = var.request_payer == null ? 0 : 1

  bucket = aws_s3_bucket.this.id
  payer  = var.request_payer
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count  = length(keys(var.server_side_encryption_configuration)) == 0 ? 0 : 1
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = [lookup(var.server_side_encryption_configuration, "rule")]

    content {
      bucket_key_enabled = lookup(rule.value, "bucket_key_enabled", null)

      dynamic "apply_server_side_encryption_by_default" {
        for_each = length(keys(lookup(rule.value, "apply_server_side_encryption_by_default", {}))) == 0 ? [] : [
        lookup(rule.value, "apply_server_side_encryption_by_default", {})]

        content {
          sse_algorithm     = apply_server_side_encryption_by_default.value.sse_algorithm
          kms_master_key_id = lookup(apply_server_side_encryption_by_default.value, "kms_master_key_id", null)
        }
      }
    }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  count  = length(keys(var.versioning)) == 0 ? 0 : 1
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status     = lookup(var.versioning, "enabled", true) ? "Enabled" : "Suspended"
    mfa_delete = lookup(var.versioning, "mfa_delete", null)
  }
}

resource "aws_s3_bucket_website_configuration" "this" {
  count  = length(keys(var.website)) == 0 ? 0 : 1
  bucket = aws_s3_bucket.this.id

  dynamic "index_document" {
    for_each = lookup(var.website, "index_document", "") == "" ? [] : [lookup(var.website, "index_document")]
    content {
      suffix = index_document.value
    }
  }

  dynamic "error_document" {
    for_each = lookup(var.website, "error_document", "") == "" ? [] : [lookup(var.website, "error_document")]
    content {
      key = error_document.value
    }
  }

  dynamic "redirect_all_requests_to" {
    for_each = length(try(jsondecode(lookup(var.website, "redirect_all_requests_to", "")), [])) > 0 ? try(jsondecode(lookup(var.website, "redirect_all_requests_to", "")), []) : []
    content {
      host_name = lookup(redirect_all_requests_to.value, "host_name", null)
      protocol  = lookup(redirect_all_requests_to.value, "protocol", null)
    }
  }

  dynamic "routing_rule" {
    for_each = length(try(jsondecode(lookup(var.website, "routing_rules", "")), [])) > 0 ? try(jsondecode(lookup(var.website, "routing_rules", "")), []) : []

    content {
      dynamic "condition" {
        for_each = length(keys(lookup(routing_rule.value, "condition", {}))) == 0 ? [] : [lookup(routing_rule.value, "condition")]

        content {
          http_error_code_returned_equals = lookup(condition.value, "http_error_code_returned_equals", null)
          key_prefix_equals               = lookup(condition.value, "key_prefix_equals", null)
        }
      }

      dynamic "redirect" {
        for_each = [lookup(routing_rule.value, "redirect")]

        content {
          host_name               = lookup(redirect.value, "host_name", null)
          http_redirect_code      = lookup(redirect.value, "http_redirect_code", null)
          protocol                = lookup(redirect.value, "protocol", null)
          replace_key_prefix_with = lookup(redirect.value, "replace_key_prefix_with", null)
          replace_key_with        = lookup(redirect.value, "replace_key_with", null)
        }
      }
    }
  }
}
