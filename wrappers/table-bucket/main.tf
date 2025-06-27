module "wrapper" {
  source = "../../modules/table-bucket"

  for_each = var.items

  create                                 = try(each.value.create, var.defaults.create, true)
  create_table_bucket_policy             = try(each.value.create_table_bucket_policy, var.defaults.create_table_bucket_policy, false)
  encryption_configuration               = try(each.value.encryption_configuration, var.defaults.encryption_configuration, null)
  maintenance_configuration              = try(each.value.maintenance_configuration, var.defaults.maintenance_configuration, null)
  region                                 = try(each.value.region, var.defaults.region, null)
  table_bucket_name                      = try(each.value.table_bucket_name, var.defaults.table_bucket_name, null)
  table_bucket_override_policy_documents = try(each.value.table_bucket_override_policy_documents, var.defaults.table_bucket_override_policy_documents, [])
  table_bucket_policy                    = try(each.value.table_bucket_policy, var.defaults.table_bucket_policy, null)
  table_bucket_policy_statements         = try(each.value.table_bucket_policy_statements, var.defaults.table_bucket_policy_statements, {})
  table_bucket_source_policy_documents   = try(each.value.table_bucket_source_policy_documents, var.defaults.table_bucket_source_policy_documents, [])
  tables                                 = try(each.value.tables, var.defaults.tables, {})
}
