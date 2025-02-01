module "wrapper" {
  source = "../../modules/directory-bucket"

  for_each = var.items

  availability_zone_id                 = try(each.value.availability_zone_id, var.defaults.availability_zone_id, null)
  bucket_name_prefix                   = try(each.value.bucket_name_prefix, var.defaults.bucket_name_prefix, null)
  create                               = try(each.value.create, var.defaults.create, true)
  create_bucket_policy                 = try(each.value.create_bucket_policy, var.defaults.create_bucket_policy, false)
  data_redundancy                      = try(each.value.data_redundancy, var.defaults.data_redundancy, null)
  force_destroy                        = try(each.value.force_destroy, var.defaults.force_destroy, null)
  lifecycle_rules                      = try(each.value.lifecycle_rules, var.defaults.lifecycle_rules, {})
  location_type                        = try(each.value.location_type, var.defaults.location_type, null)
  override_policy_documents            = try(each.value.override_policy_documents, var.defaults.override_policy_documents, [])
  policy_statements                    = try(each.value.policy_statements, var.defaults.policy_statements, {})
  server_side_encryption_configuration = try(each.value.server_side_encryption_configuration, var.defaults.server_side_encryption_configuration, {})
  source_policy_documents              = try(each.value.source_policy_documents, var.defaults.source_policy_documents, [])
  type                                 = try(each.value.type, var.defaults.type, "Directory")
}
