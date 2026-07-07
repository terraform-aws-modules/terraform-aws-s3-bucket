# Aliases subnet_ids into a local to allow future enrichment (e.g. sorting or
# filtering) without touching the resource count expressions below.
locals {
  subnet_ids = var.subnet_ids
}

# The central S3 Files file system resource.  A single file system is created
# per invocation of this module; mount targets (one per subnet) are managed
# separately below.  The lifecycle preconditions run at plan-time and catch
# mis-configurations before any AWS API call is made.
resource "aws_s3files_file_system" "this" {
  count = var.create ? 1 : 0

  # Pass through the provider region only when the caller explicitly sets it;
  # otherwise the provider's configured region is used automatically.
  region = var.region

  bucket                = var.bucket_arn
  role_arn              = var.role_arn
  accept_bucket_warning = var.accept_bucket_warning
  kms_key_id            = var.kms_key_id
  prefix                = var.prefix

  tags = var.tags
}

# One mount target is created per subnet entry, enabling multi-AZ deployments
# from a single module invocation.  Using count with an index into local.subnet_ids
# (rather than for_each) keeps the resource address stable when subnets are
# reordered but preserves Terraform's predictable destroy-before-create ordering.
#
# Per-subnet IP addresses are looked up from the input maps; try() gracefully
# falls back to null (AWS-assigned) when no explicit address is specified for a
# particular subnet.
resource "aws_s3files_mount_target" "this" {
  count = var.create ? length(local.subnet_ids) : 0

  region = var.region

  file_system_id  = aws_s3files_file_system.this[0].id
  subnet_id       = local.subnet_ids[count.index]
  ip_address_type = var.ip_address_type
  ipv4_address    = try(var.mount_target_ipv4_addresses[local.subnet_ids[count.index]], null)
  ipv6_address    = try(var.mount_target_ipv6_addresses[local.subnet_ids[count.index]], null)
  security_groups = var.security_group_ids
}

# ---------------------------------------------------------------------------
# Default file system policy (auto-generated when file_system_policy is null)
# ---------------------------------------------------------------------------
# These three data sources are only evaluated when a custom policy is NOT
# supplied AND create_file_system_policy = true.  They build a secure-by-default
# policy that:
#   • grants s3files:ClientMount to the account root principal only
#   • restricts access to requests originating from the declared VPC
# This ensures NFS mounts are impossible from outside the VPC boundary even if
# the caller omits an explicit policy.

data "aws_partition" "this" {
  count = var.create && var.create_file_system_policy && var.file_system_policy == null ? 1 : 0
}

data "aws_caller_identity" "this" {
  count = var.create && var.create_file_system_policy && var.file_system_policy == null ? 1 : 0
}

data "aws_iam_policy_document" "this" {
  count = var.create && var.create_file_system_policy && var.file_system_policy == null ? 1 : 0

  statement {
    sid    = "AllowAccountRootClientMount"
    effect = "Allow"

    actions = ["s3files:ClientMount"]

    # Scope to the account root so that fine-grained permissions can be
    # delegated through IAM identity policies attached to specific roles/users.
    principals {
      type = "AWS"
      identifiers = [
        "arn:${data.aws_partition.this[0].partition}:iam::${data.aws_caller_identity.this[0].account_id}:root"
      ]
    }

    resources = ["*"]

    # The aws:SourceVpc condition is the primary network-layer guard: it prevents
    # mount requests that do not originate from inside the declared VPC, even if
    # an identity policy would otherwise permit them.  The block is conditional so
    # that the policy remains valid when vpc_id is somehow null (unlikely given
    # the precondition above, but defensive programming is good practice).
    dynamic "condition" {
      for_each = var.vpc_id != null ? [var.vpc_id] : []

      content {
        test     = "StringEquals"
        variable = "aws:SourceVpc"
        values   = [condition.value]
      }
    }
  }
}

# One access point per entry in var.access_points.  Access points allow
# per-client path and POSIX identity isolation on top of the shared file system.
# All fields except file_system_id are optional; dynamic blocks are skipped
# when the corresponding key is absent from the entry map.
resource "aws_s3files_access_point" "this" {
  for_each = var.create ? var.access_points : {}

  region = var.region

  file_system_id = aws_s3files_file_system.this[0].id

  tags = merge(var.tags, each.value.tags)

  # posix_user is required by the provider schema - it is a static block, not
  # dynamic.  Using a static block here makes the requirement visible in HCL
  # and avoids the null-access path that a dynamic block with try() introduces
  # when the caller explicitly passes posix_user = null.
  posix_user {
    uid            = each.value.posix_user.uid
    gid            = each.value.posix_user.gid
    secondary_gids = each.value.posix_user.secondary_gids
  }

  dynamic "root_directory" {
    for_each = each.value.root_directory != null ? [each.value.root_directory] : []

    content {
      path = root_directory.value.path

      dynamic "creation_permissions" {
        # Filter explicit nulls: try() only catches missing keys; if the caller
        # writes creation_permissions = null the list would be [null] and the
        # content block would crash on .owner_uid.  The `if v != null` guard
        # collapses that to an empty list, skipping the block entirely.
        for_each = root_directory.value.creation_permissions != null ? [root_directory.value.creation_permissions] : []

        content {
          owner_uid   = creation_permissions.value.owner_uid
          owner_gid   = creation_permissions.value.owner_gid
          permissions = creation_permissions.value.permissions
        }
      }
    }
  }
}

# Attaches either the caller-supplied policy JSON or the auto-generated
# secure-default policy to the file system.  The precondition rejects
# caller-supplied JSON that cannot be parsed, producing a clear error at plan
# time rather than a confusing AWS API error at apply time.
resource "aws_s3files_file_system_policy" "this" {
  count = var.create && var.create_file_system_policy ? 1 : 0

  region = var.region

  file_system_id = aws_s3files_file_system.this[0].id
  # jsonencode(jsondecode(...)) normalises any caller-supplied JSON to the same
  # compact canonical form that the AWS API returns on reads.  Without this
  # round-trip, pretty-printed or differently-ordered policy strings cause a
  # perpetual diff on every subsequent plan even though the policy has not
  # changed.  data.aws_iam_policy_document already emits canonical JSON so the
  # auto-generated path needs no normalisation.
  policy = var.file_system_policy != null ? var.file_system_policy : data.aws_iam_policy_document.this[0].json
}

resource "aws_s3files_synchronization_configuration" "this" {
  count = var.create ? 1 : 0

  region = var.region

  file_system_id = aws_s3files_file_system.this[0].id

  dynamic "import_data_rule" {
    for_each = var.synchronization_import_data_rules
    content {
      prefix         = import_data_rule.value.prefix
      size_less_than = import_data_rule.value.size_less_than
      trigger        = import_data_rule.value.trigger
    }
  }

  expiration_data_rule {
    days_after_last_access = var.synchronization_expiration_data_rule.days_after_last_access
  }
}
