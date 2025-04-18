module "wrapper" {
  source = "../../modules/account-public-access"

  for_each = var.items

  account_id              = try(each.value.account_id, var.defaults.account_id, null)
  block_public_acls       = try(each.value.block_public_acls, var.defaults.block_public_acls, false)
  block_public_policy     = try(each.value.block_public_policy, var.defaults.block_public_policy, false)
  create                  = try(each.value.create, var.defaults.create, true)
  ignore_public_acls      = try(each.value.ignore_public_acls, var.defaults.ignore_public_acls, false)
  restrict_public_buckets = try(each.value.restrict_public_buckets, var.defaults.restrict_public_buckets, false)
}
