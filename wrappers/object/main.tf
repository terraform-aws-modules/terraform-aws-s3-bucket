module "wrapper" {
  source = "../../modules/object"

  for_each = var.items

  create                        = lookup(each.value, "create", true)
  bucket                        = lookup(each.value, "bucket", "")
  key                           = lookup(each.value, "key", "")
  file_source                   = lookup(each.value, "file_source", null)
  content                       = lookup(each.value, "content", null)
  content_base64                = lookup(each.value, "content_base64", null)
  acl                           = lookup(each.value, "acl", null)
  cache_control                 = lookup(each.value, "cache_control", null)
  content_disposition           = lookup(each.value, "content_disposition", null)
  content_encoding              = lookup(each.value, "content_encoding", null)
  content_language              = lookup(each.value, "content_language", null)
  content_type                  = lookup(each.value, "content_type", null)
  website_redirect              = lookup(each.value, "website_redirect", null)
  storage_class                 = lookup(each.value, "storage_class", null)
  etag                          = lookup(each.value, "etag", null)
  server_side_encryption        = lookup(each.value, "server_side_encryption", null)
  kms_key_id                    = lookup(each.value, "kms_key_id", null)
  bucket_key_enabled            = lookup(each.value, "bucket_key_enabled", null)
  metadata                      = lookup(each.value, "metadata", {})
  tags                          = lookup(each.value, "tags", {})
  force_destroy                 = lookup(each.value, "force_destroy", false)
  object_lock_legal_hold_status = lookup(each.value, "object_lock_legal_hold_status", null)
  object_lock_mode              = lookup(each.value, "object_lock_mode", null)
  object_lock_retain_until_date = lookup(each.value, "object_lock_retain_until_date", null)
}
