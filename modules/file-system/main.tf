data "aws_caller_identity" "current" {
  count = local.create ? 1 : 0
}

data "aws_partition" "current" {
  count = local.create ? 1 : 0
}

data "aws_region" "current" {
  count = local.create ? 1 : 0

  region = var.region
}

locals {
  create = var.create

  account_id = try(data.aws_caller_identity.current[0].account_id, "")
  dns_suffix = try(data.aws_partition.current[0].dns_suffix, "")
  partition  = try(data.aws_partition.current[0].partition, "")
  region     = try(data.aws_region.current[0].region, "")
}

################################################################################
# File System
################################################################################

resource "aws_s3files_file_system" "this" {
  count = local.create ? 1 : 0

  region = var.region

  bucket                = var.bucket_arn
  prefix                = var.prefix
  role_arn              = var.create_iam_role ? aws_iam_role.this[0].arn : var.iam_role_arn
  kms_key_id            = var.kms_key_id
  accept_bucket_warning = var.accept_bucket_warning

  tags = merge(
    var.tags,
    var.name != null ? { Name = var.name } : {}
  )

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
    }
  }

  lifecycle {
    # Referencing the versioning status is also what orders the file system after the bucket's
    # versioning on create, and before it on destroy, when the caller passes that resource's attribute
    precondition {
      condition     = var.bucket_versioning_status == "Enabled"
      error_message = "S3 Files requires versioning to be enabled on the bucket."
    }

    # A directory bucket ARN names the s3express service, and S3 Files does not support one
    precondition {
      condition     = can(regex("^arn:[^:]*:s3:::", var.bucket_arn))
      error_message = "S3 Files supports general purpose buckets only, so bucket_arn must look like arn:aws:s3:::my-bucket."
    }
  }

  depends_on = [
    # The role has to be able to reach the bucket for as long as the file system exists
    aws_iam_role_policy.this,
  ]
}

################################################################################
# IAM Role
################################################################################

locals {
  create_iam_role = local.create && var.create_iam_role

  # Without a name to build on, the provider generates one
  iam_role_name = var.iam_role_name != null ? var.iam_role_name : (var.name != null ? "${var.name}-s3files" : null)
}

data "aws_service_principal" "elasticfilesystem" {
  count = local.create_iam_role ? 1 : 0

  service_name = "elasticfilesystem"
  region       = local.region
}

data "aws_iam_policy_document" "assume_role" {
  count = local.create_iam_role ? 1 : 0

  statement {
    sid     = "AllowS3FilesAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = [data.aws_service_principal.elasticfilesystem[0].name]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }

    # The role exists before its file system, so the trust cannot name one file system
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:${local.partition}:s3files:${local.region}:${local.account_id}:file-system/*"]
    }
  }
}

resource "aws_iam_role" "this" {
  count = local.create_iam_role ? 1 : 0

  name        = var.iam_role_use_name_prefix ? null : local.iam_role_name
  name_prefix = var.iam_role_use_name_prefix && local.iam_role_name != null ? "${local.iam_role_name}-" : null
  path        = var.iam_role_path
  description = var.iam_role_description

  assume_role_policy    = data.aws_iam_policy_document.assume_role[0].json
  permissions_boundary  = var.iam_role_permissions_boundary
  force_detach_policies = true

  tags = merge(var.tags, var.iam_role_tags)
}

data "aws_iam_policy_document" "this" {
  count = local.create_iam_role ? 1 : 0

  statement {
    sid = "S3BucketPermissions"
    actions = [
      "s3:ListBucket",
      "s3:ListBucketVersions",
    ]
    resources = [var.bucket_arn]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceAccount"
      values   = [local.account_id]
    }
  }

  statement {
    sid = "S3ObjectPermissions"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject*",
      "s3:GetObject*",
      "s3:List*",
      "s3:PutObject*",
    ]
    resources = ["${var.bucket_arn}/${var.prefix != null ? var.prefix : ""}*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceAccount"
      values   = [local.account_id]
    }
  }

  statement {
    sid = "UseKmsKeyWithS3Files"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:ReEncryptFrom",
      "kms:ReEncryptTo",
    ]
    resources = ["arn:${local.partition}:kms:${local.region}:${local.account_id}:*"]

    condition {
      test     = "StringLike"
      variable = "kms:ViaService"
      values   = ["s3.${local.region}.${local.dns_suffix}"]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:s3:arn"
      values = [
        var.bucket_arn,
        "${var.bucket_arn}/${var.prefix != null ? var.prefix : ""}*",
      ]
    }
  }

  # S3 Files manages its own EventBridge rule to detect changes in the bucket
  statement {
    sid = "EventBridgeManage"
    actions = [
      "events:DeleteRule",
      "events:DisableRule",
      "events:EnableRule",
      "events:PutRule",
      "events:PutTargets",
      "events:RemoveTargets",
    ]
    resources = ["arn:${local.partition}:events:*:*:rule/DO-NOT-DELETE-S3-Files*"]

    condition {
      test     = "StringEquals"
      variable = "events:ManagedBy"
      values   = [data.aws_service_principal.elasticfilesystem[0].name]
    }
  }

  statement {
    sid = "EventBridgeRead"
    actions = [
      "events:DescribeRule",
      "events:ListRuleNamesByTarget",
      "events:ListRules",
      "events:ListTargetsByRule",
    ]
    resources = ["arn:${local.partition}:events:*:*:rule/*"]
  }
}

resource "aws_iam_role_policy" "this" {
  count = local.create_iam_role ? 1 : 0

  name   = "S3Files"
  role   = aws_iam_role.this[0].id
  policy = data.aws_iam_policy_document.this[0].json
}

################################################################################
# Mount Target(s)
################################################################################

resource "aws_s3files_mount_target" "this" {
  for_each = { for k, v in var.mount_targets : k => v if local.create }

  region = var.region

  file_system_id  = aws_s3files_file_system.this[0].id
  subnet_id       = each.value.subnet_id
  ip_address_type = each.value.ip_address_type
  ipv4_address    = each.value.ipv4_address
  ipv6_address    = each.value.ipv6_address
  security_groups = var.security_groups != null ? var.security_groups : (local.create_security_group ? [aws_security_group.this[0].id] : null)

  dynamic "timeouts" {
    for_each = each.value.timeouts != null ? [each.value.timeouts] : []

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      update = timeouts.value.update
    }
  }
}

################################################################################
# Security Group
################################################################################

locals {
  # Only created when the mount targets rely on it rather than on groups the caller supplies
  # Whether there are mount targets is deliberately not part of this: they can be keyed by a value only
  # known after apply, which would make this count unknown at plan time. A VPC is required instead, so a
  # file system without one never puts a group in the default VPC
  create_security_group = local.create && var.create_security_group && var.security_groups == null && var.security_group_vpc_id != null

  # Without a name to build on, the provider generates one
  security_group_name = var.security_group_name != null ? var.security_group_name : (var.name != null ? "${var.name}-s3files" : null)
}

resource "aws_security_group" "this" {
  count = local.create_security_group ? 1 : 0

  region = var.region

  name        = var.security_group_use_name_prefix ? null : local.security_group_name
  name_prefix = var.security_group_use_name_prefix && local.security_group_name != null ? "${local.security_group_name}-" : null
  description = var.security_group_description

  revoke_rules_on_delete = true
  vpc_id                 = var.security_group_vpc_id

  tags = merge(
    var.tags,
    local.security_group_name != null ? { Name = local.security_group_name } : {},
    var.security_group_tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = { for k, v in var.security_group_ingress_rules : k => v if local.create_security_group }

  region = var.region

  cidr_ipv4                    = each.value.cidr_ipv4
  cidr_ipv6                    = each.value.cidr_ipv6
  description                  = each.value.description
  from_port                    = each.value.from_port
  ip_protocol                  = each.value.ip_protocol
  prefix_list_id               = each.value.prefix_list_id
  referenced_security_group_id = each.value.referenced_security_group_id == "self" ? aws_security_group.this[0].id : each.value.referenced_security_group_id
  security_group_id            = aws_security_group.this[0].id
  to_port                      = each.value.to_port

  tags = merge(
    var.tags,
    { Name = each.value.name != null ? each.value.name : (local.security_group_name != null ? "${local.security_group_name}-${each.key}" : each.key) },
    each.value.tags
  )
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = { for k, v in var.security_group_egress_rules : k => v if local.create_security_group }

  region = var.region

  cidr_ipv4                    = each.value.cidr_ipv4
  cidr_ipv6                    = each.value.cidr_ipv6
  description                  = each.value.description
  from_port                    = each.value.from_port
  ip_protocol                  = each.value.ip_protocol
  prefix_list_id               = each.value.prefix_list_id
  referenced_security_group_id = each.value.referenced_security_group_id == "self" ? aws_security_group.this[0].id : each.value.referenced_security_group_id
  security_group_id            = aws_security_group.this[0].id
  to_port                      = each.value.to_port

  tags = merge(
    var.tags,
    { Name = each.value.name != null ? each.value.name : (local.security_group_name != null ? "${local.security_group_name}-${each.key}" : each.key) },
    each.value.tags
  )
}

################################################################################
# Access Point(s)
################################################################################

resource "aws_s3files_access_point" "this" {
  for_each = { for k, v in var.access_points : k => v if local.create }

  region = var.region

  file_system_id = aws_s3files_file_system.this[0].id

  dynamic "posix_user" {
    for_each = each.value.posix_user != null ? [each.value.posix_user] : []

    content {
      gid            = posix_user.value.gid
      uid            = posix_user.value.uid
      secondary_gids = posix_user.value.secondary_gids
    }
  }

  dynamic "root_directory" {
    for_each = each.value.root_directory != null ? [each.value.root_directory] : []

    content {
      path = root_directory.value.path

      dynamic "creation_permissions" {
        for_each = root_directory.value.creation_permissions != null ? [root_directory.value.creation_permissions] : []

        content {
          owner_gid   = creation_permissions.value.owner_gid
          owner_uid   = creation_permissions.value.owner_uid
          permissions = creation_permissions.value.permissions
        }
      }
    }
  }

  tags = merge(
    var.tags,
    { Name = coalesce(each.value.name, each.key) },
    each.value.tags
  )

  dynamic "timeouts" {
    for_each = each.value.timeouts != null ? [each.value.timeouts] : []

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
    }
  }
}

################################################################################
# File System Policy
################################################################################

locals {
  # Actions each access level grants through an access point
  access_point_actions = {
    read       = ["s3files:ClientMount"]
    read_write = ["s3files:ClientMount", "s3files:ClientWrite"]
  }

  # One entry per access point and access level that names principals
  access_point_grants = flatten([
    for ap_key, ap in var.access_points : [
      for level, principals in { read = ap.read_access_arns, read_write = ap.read_write_access_arns } : {
        access_point                  = ap_key
        actions                       = local.access_point_actions[level]
        principals                    = principals
      } if try(length(principals), 0) > 0
    ]
  ])

  # A policy exists whenever the caller sets statements or lists principals on an access point, so neither is silently
  # ignored. Presence is tested rather than length, which is unknown at plan time for a list built from computed values
  create_policy = local.create && (
    var.policy_statements != null ||
    length(var.source_policy_documents) > 0 ||
    length(var.override_policy_documents) > 0 ||
    anytrue([for ap in values(var.access_points) : ap.read_access_arns != null || ap.read_write_access_arns != null])
  )
}

data "aws_iam_policy_document" "policy" {
  count = local.create_policy ? 1 : 0

  source_policy_documents   = var.source_policy_documents
  override_policy_documents = var.override_policy_documents

  dynamic "statement" {
    for_each = var.policy_statements != null ? var.policy_statements : []

    content {
      sid           = statement.value.sid
      actions       = statement.value.actions
      not_actions   = statement.value.not_actions
      effect        = statement.value.effect
      resources     = statement.value.resources != null || statement.value.not_resources != null ? statement.value.resources : [aws_s3files_file_system.this[0].arn]
      not_resources = statement.value.not_resources

      dynamic "principals" {
        for_each = statement.value.principals != null ? statement.value.principals : []

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = statement.value.not_principals != null ? statement.value.not_principals : []

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = statement.value.conditions != null ? statement.value.conditions : []

        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }

  # Allow each listed principal through its access point
  dynamic "statement" {
    for_each = local.access_point_grants

    content {
      effect    = "Allow"
      actions   = statement.value.actions
      resources = [aws_s3files_file_system.this[0].arn]

      principals {
        type        = "AWS"
        identifiers = statement.value.principals
      }

      condition {
        test     = "StringEquals"
        variable = "s3files:AccessPointArn"
        values   = [aws_s3files_access_point.this[statement.value.access_point].arn]
      }
    }
  }

  # Deny each listed principal through every other access point. An allow alone does not restrict,
  # because allows are additive across identity and resource policies
  dynamic "statement" {
    for_each = {
      for pair in flatten([
        for g in local.access_point_grants : [
          for principal in g.principals : { principal = principal, access_point = g.access_point }
        ]
      ]) : pair.principal => pair.access_point...
    }

    content {
      effect    = "Deny"
      actions   = ["s3files:Client*"]
      resources = [aws_s3files_file_system.this[0].arn]

      principals {
        type        = "AWS"
        identifiers = [statement.key]
      }

      condition {
        test     = "StringNotEquals"
        variable = "s3files:AccessPointArn"
        values   = [for ap in distinct(statement.value) : aws_s3files_access_point.this[ap].arn]
      }
    }
  }
}

resource "aws_s3files_file_system_policy" "this" {
  count = local.create_policy ? 1 : 0

  region = var.region

  file_system_id = aws_s3files_file_system.this[0].id
  policy         = data.aws_iam_policy_document.policy[0].json
}

################################################################################
# Synchronization Configuration
################################################################################

resource "aws_s3files_synchronization_configuration" "this" {
  count = local.create && var.synchronization_configuration != null ? 1 : 0

  region = var.region

  file_system_id = aws_s3files_file_system.this[0].id

  dynamic "import_data_rule" {
    for_each = var.synchronization_configuration.import_data_rule

    content {
      prefix         = import_data_rule.value.prefix
      size_less_than = import_data_rule.value.size_less_than
      trigger        = import_data_rule.value.trigger
    }
  }

  expiration_data_rule {
    days_after_last_access = var.synchronization_configuration.expiration_data_rule.days_after_last_access
  }
}
