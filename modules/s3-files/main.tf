# Aliases subnet_ids into a local to allow future enrichment (e.g. sorting or
# filtering) without touching the resource count expressions below.
locals {
  subnet_ids = var.subnet_ids
}

# Fetched at plan-time so that the precondition on aws_s3files_file_system can
# verify that every supplied subnet belongs to the declared vpc_id.  The lookup
# is skipped entirely when create = false to avoid unnecessary API calls.
data "aws_subnet" "this" {
  count = var.create ? length(var.subnet_ids) : 0

  id = var.subnet_ids[count.index]
}

# Fetched at plan-time for the same reason as aws_subnet.this: the precondition
# asserts that all security groups reside in the same VPC as the mount targets.
data "aws_security_group" "this" {
  count = var.create ? length(var.security_group_ids) : 0

  id = var.security_group_ids[count.index]
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

  bucket                = var.s3_uri
  role_arn              = var.role_arn
  accept_bucket_warning = var.accept_bucket_warning
  kms_key_id            = var.kms_key_id
  prefix                = var.prefix

  tags = var.tags

  lifecycle {
    # Guard 1 – s3_uri must be a well-formed S3 bucket ARN.
    # S3 ARNs take the form arn:<partition>:s3:::<bucket-name> with no region
    # or account-id segments.  Bucket names are 3–63 characters and may only
    # contain lowercase letters, numbers, hyphens, and dots.
    precondition {
      condition = (
        var.s3_uri != null &&
        trimspace(var.s3_uri) != "" &&
        can(regex("^arn:[^:]+:s3:::[A-Za-z0-9][A-Za-z0-9.-]{1,61}[A-Za-z0-9]$", var.s3_uri))
      )
      error_message = "s3_uri must be a valid S3 bucket ARN, for example arn:aws:s3:::my-bucket."
    }

    # Guard 2 – role_arn must be a well-formed IAM role ARN.
    # The IAM role is assumed by the S3 Files service to access the S3 bucket
    # on behalf of NFS clients.
    precondition {
      condition = (
        var.role_arn != null &&
        trimspace(var.role_arn) != "" &&
        can(regex("^arn:[^:]+:iam::[0-9]{12}:role\\/.+", var.role_arn))
      )
      error_message = "role_arn must be a valid IAM role ARN."
    }

    # Guard 3 – vpc_id must be a well-formed VPC identifier (vpc-<hex>).
    # This is required because mount targets must be placed inside a VPC and
    # the preconditions for subnet and security group membership depend on it.
    precondition {
      condition = (
        var.vpc_id != null &&
        trimspace(var.vpc_id) != "" &&
        can(regex("^vpc-[0-9a-f]+$", var.vpc_id))
      )
      error_message = "vpc_id must be a valid VPC ID."
    }

    # Guard 4 – at least one subnet must be supplied.
    # A file system with no mount targets is unreachable from VPC clients.
    precondition {
      condition     = length(var.subnet_ids) > 0
      error_message = "At least one subnet ID must be provided in subnet_ids when create is true."
    }

    # Guard 5 – subnet IDs must be unique.
    # AWS allows only one mount target per subnet per file system; duplicates
    # would cause a 409 ConflictException on the second mount target creation.
    precondition {
      condition     = length(distinct(var.subnet_ids)) == length(var.subnet_ids)
      error_message = "subnet_ids must not contain duplicates."
    }

    # Guard 6 – every subnet must belong to the declared VPC.
    # Cross-VPC subnets are invalid; catching this early produces a clear error
    # instead of a cryptic AWS API failure.
    precondition {
      condition     = alltrue([for subnet in data.aws_subnet.this : subnet.vpc_id == var.vpc_id])
      error_message = "All subnet_ids must belong to the provided vpc_id."
    }

    # Guard 7 – every security group must belong to the declared VPC.
    # Security groups are VPC-scoped; attaching one from a different VPC is an
    # API error.  The check is skipped when no security groups are provided.
    precondition {
      condition = (
        length(var.security_group_ids) == 0 ||
        alltrue([for security_group in data.aws_security_group.this : security_group.vpc_id == var.vpc_id])
      )
      error_message = "All security_group_ids must belong to the provided vpc_id."
    }

    # Guard 8 – IPv4 address map keys must be a subset of subnet_ids.
    # If a key does not match any subnet, the entry would be silently ignored;
    # an explicit error is much easier to debug.
    precondition {
      condition = length(
        setsubtract(toset(keys(var.mount_target_ipv4_addresses)), toset(var.subnet_ids))
      ) == 0
      error_message = "mount_target_ipv4_addresses keys must match values provided in subnet_ids."
    }

    # Guard 9 – IPv6 address map keys must be a subset of subnet_ids.
    precondition {
      condition = length(
        setsubtract(toset(keys(var.mount_target_ipv6_addresses)), toset(var.subnet_ids))
      ) == 0
      error_message = "mount_target_ipv6_addresses keys must match values provided in subnet_ids."
    }
  }
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

# Attaches either the caller-supplied policy JSON or the auto-generated
# secure-default policy to the file system.  The precondition rejects
# caller-supplied JSON that cannot be parsed, producing a clear error at plan
# time rather than a confusing AWS API error at apply time.
resource "aws_s3files_file_system_policy" "this" {
  count = var.create && var.create_file_system_policy ? 1 : 0

  region = var.region

  file_system_id = aws_s3files_file_system.this[0].id
  policy         = var.file_system_policy != null ? var.file_system_policy : data.aws_iam_policy_document.this[0].json

  lifecycle {
    # Validate that a custom policy string is parseable JSON before applying.
    # jsondecode() throws on invalid JSON; can() converts that to a bool.
    precondition {
      condition     = var.file_system_policy == null || can(jsondecode(var.file_system_policy))
      error_message = "file_system_policy must be valid JSON when provided."
    }
  }
}
