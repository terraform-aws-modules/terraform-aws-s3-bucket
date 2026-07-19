resource "aws_s3files_file_system" "this" {
  count = var.create ? 1 : 0

  region = var.region

  bucket                = var.bucket_arn
  role_arn              = var.role_arn
  accept_bucket_warning = var.accept_bucket_warning
  kms_key_id            = var.kms_key_id
  prefix                = var.prefix

  tags = var.tags
}

resource "aws_s3files_mount_target" "this" {
  count = var.create ? length(var.subnet_ids) : 0

  region = var.region

  file_system_id  = aws_s3files_file_system.this[0].id
  subnet_id       = var.subnet_ids[count.index]
  ip_address_type = var.ip_address_type
  ipv4_address    = try(var.mount_target_ipv4_addresses[var.subnet_ids[count.index]], null)
  ipv6_address    = try(var.mount_target_ipv6_addresses[var.subnet_ids[count.index]], null)
  security_groups = var.security_group_ids
}

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

    principals {
      type = "AWS"
      identifiers = [
        "arn:${data.aws_partition.this[0].partition}:iam::${data.aws_caller_identity.this[0].account_id}:root"
      ]
    }

    resources = ["*"]

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

resource "aws_s3files_access_point" "this" {
  for_each = var.create ? var.access_points : {}

  region = var.region

  file_system_id = aws_s3files_file_system.this[0].id

  tags = merge(var.tags, each.value.tags)

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

resource "aws_s3files_file_system_policy" "this" {
  count = var.create && var.create_file_system_policy ? 1 : 0

  region = var.region

  file_system_id = aws_s3files_file_system.this[0].id

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
