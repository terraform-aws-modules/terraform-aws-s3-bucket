module "wrapper" {
  source = "../../modules/vectors"

  for_each = var.items

  create                   = try(each.value.create, var.defaults.create, true)
  create_policy            = try(each.value.create_policy, var.defaults.create_policy, false)
  encryption_configuration = try(each.value.encryption_configuration, var.defaults.encryption_configuration, null)
  force_destroy            = try(each.value.force_destroy, var.defaults.force_destroy, false)
  indexes                  = try(each.value.indexes, var.defaults.indexes, {})
  policy                   = try(each.value.policy, var.defaults.policy, null)
  region                   = try(each.value.region, var.defaults.region, null)
  tags                     = try(each.value.tags, var.defaults.tags, {})
  vector_bucket_name       = try(each.value.vector_bucket_name, var.defaults.vector_bucket_name, null)
}
