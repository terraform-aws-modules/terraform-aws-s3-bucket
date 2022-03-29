module "wrapper" {
  source = "../../modules/object"

  for_each = var.items

  create                        = try(each.value.create, true)
  bucket                        = try(each.value.bucket, "")
  key                           = try(each.value.key, "")
  file_source                   = try(each.value.file_source, null)
  content                       = try(each.value.content, null)
  content_base64                = try(each.value.content_base64, null)
  acl                           = try(each.value.acl, null)
  cache_control                 = try(each.value.cache_control, null)
  content_disposition           = try(each.value.content_disposition, null)
  content_encoding              = try(each.value.content_encoding, null)
  content_language              = try(each.value.content_language, null)
  content_type                  = try(each.value.content_type, null)
  website_redirect              = try(each.value.website_redirect, null)
  storage_class                 = try(each.value.storage_class, null)
  etag                          = try(each.value.etag, null)
  server_side_encryption        = try(each.value.server_side_encryption, null)
  kms_key_id                    = try(each.value.kms_key_id, null)
  bucket_key_enabled            = try(each.value.bucket_key_enabled, null)
  metadata                      = try(each.value.metadata, {})
  tags                          = try(each.value.tags, {})
  force_destroy                 = try(each.value.force_destroy, false)
  object_lock_legal_hold_status = try(each.value.object_lock_legal_hold_status, null)
  object_lock_mode              = try(each.value.object_lock_mode, null)
  object_lock_retain_until_date = try(each.value.object_lock_retain_until_date, null)
}
