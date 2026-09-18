module "wrapper" {
  source = "../../modules/s3-files"

  for_each = var.items

  accept_bucket_warning       = try(each.value.accept_bucket_warning, var.defaults.accept_bucket_warning, null)
  access_points               = try(each.value.access_points, var.defaults.access_points, {})
  bucket_arn                  = try(each.value.bucket_arn, var.defaults.bucket_arn, null)
  create                      = try(each.value.create, var.defaults.create, true)
  create_file_system_policy   = try(each.value.create_file_system_policy, var.defaults.create_file_system_policy, true)
  file_system_policy          = try(each.value.file_system_policy, var.defaults.file_system_policy, null)
  ip_address_type             = try(each.value.ip_address_type, var.defaults.ip_address_type, null)
  kms_key_id                  = try(each.value.kms_key_id, var.defaults.kms_key_id, null)
  mount_target_ipv4_addresses = try(each.value.mount_target_ipv4_addresses, var.defaults.mount_target_ipv4_addresses, {})
  mount_target_ipv6_addresses = try(each.value.mount_target_ipv6_addresses, var.defaults.mount_target_ipv6_addresses, {})
  prefix                      = try(each.value.prefix, var.defaults.prefix, null)
  region                      = try(each.value.region, var.defaults.region, null)
  role_arn                    = try(each.value.role_arn, var.defaults.role_arn, null)
  security_group_ids          = try(each.value.security_group_ids, var.defaults.security_group_ids, [])
  subnet_ids                  = try(each.value.subnet_ids, var.defaults.subnet_ids, [])
  synchronization_expiration_data_rule = try(each.value.synchronization_expiration_data_rule, var.defaults.synchronization_expiration_data_rule, {
    days_after_last_access = 30
  })
  synchronization_import_data_rules = try(each.value.synchronization_import_data_rules, var.defaults.synchronization_import_data_rules, [
    {
      prefix         = ""
      size_less_than = 131072
      trigger        = "ON_DIRECTORY_FIRST_ACCESS"
    }
  ])
  tags   = try(each.value.tags, var.defaults.tags, {})
  vpc_id = try(each.value.vpc_id, var.defaults.vpc_id, null)
}
