module "wrapper" {
  source = "../../modules/object"

  for_each = var.items

  acl                           = try(each.value.acl, var.defaults.acl, null)
  bucket                        = try(each.value.bucket, var.defaults.bucket, "")
  bucket_key_enabled            = try(each.value.bucket_key_enabled, var.defaults.bucket_key_enabled, null)
  cache_control                 = try(each.value.cache_control, var.defaults.cache_control, null)
  content                       = try(each.value.content, var.defaults.content, null)
  content_base64                = try(each.value.content_base64, var.defaults.content_base64, null)
  content_disposition           = try(each.value.content_disposition, var.defaults.content_disposition, null)
  content_encoding              = try(each.value.content_encoding, var.defaults.content_encoding, null)
  content_language              = try(each.value.content_language, var.defaults.content_language, null)
  content_type                  = try(each.value.content_type, var.defaults.content_type, null)
  create                        = try(each.value.create, var.defaults.create, true)
  etag                          = try(each.value.etag, var.defaults.etag, null)
  file_source                   = try(each.value.file_source, var.defaults.file_source, null)
  force_destroy                 = try(each.value.force_destroy, var.defaults.force_destroy, false)
  key                           = try(each.value.key, var.defaults.key, "")
  kms_key_id                    = try(each.value.kms_key_id, var.defaults.kms_key_id, null)
  metadata                      = try(each.value.metadata, var.defaults.metadata, {})
  object_lock_legal_hold_status = try(each.value.object_lock_legal_hold_status, var.defaults.object_lock_legal_hold_status, null)
  object_lock_mode              = try(each.value.object_lock_mode, var.defaults.object_lock_mode, null)
  object_lock_retain_until_date = try(each.value.object_lock_retain_until_date, var.defaults.object_lock_retain_until_date, null)
  server_side_encryption        = try(each.value.server_side_encryption, var.defaults.server_side_encryption, null)
  source_hash                   = try(each.value.source_hash, var.defaults.source_hash, null)
  storage_class                 = try(each.value.storage_class, var.defaults.storage_class, null)
  tags                          = try(each.value.tags, var.defaults.tags, {})
  website_redirect              = try(each.value.website_redirect, var.defaults.website_redirect, null)
}
