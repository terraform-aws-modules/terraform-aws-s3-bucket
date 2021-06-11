module "wrapper" {
  source = "../"

  for_each = var.items

  create_bucket                         = lookup(each.value, "create_bucket", true)
  attach_elb_log_delivery_policy        = lookup(each.value, "attach_elb_log_delivery_policy", false)
  attach_lb_log_delivery_policy         = lookup(each.value, "attach_lb_log_delivery_policy", false)
  attach_deny_insecure_transport_policy = lookup(each.value, "attach_deny_insecure_transport_policy", false)
  attach_policy                         = lookup(each.value, "attach_policy", false)
  attach_public_policy                  = lookup(each.value, "attach_public_policy", true)
  bucket                                = lookup(each.value, "bucket", null)
  bucket_prefix                         = lookup(each.value, "bucket_prefix", null)
  acl                                   = lookup(each.value, "acl", "private")
  policy                                = lookup(each.value, "policy", null)
  tags                                  = lookup(each.value, "tags", {})
  force_destroy                         = lookup(each.value, "force_destroy", false)
  acceleration_status                   = lookup(each.value, "acceleration_status", null)
  request_payer                         = lookup(each.value, "request_payer", null)
  website                               = lookup(each.value, "website", {})
  cors_rule                             = lookup(each.value, "cors_rule", [])
  versioning                            = lookup(each.value, "versioning", {})
  logging                               = lookup(each.value, "logging", {})
  grant                                 = lookup(each.value, "grant", [])
  lifecycle_rule                        = lookup(each.value, "lifecycle_rule", [])
  replication_configuration             = lookup(each.value, "replication_configuration", {})
  server_side_encryption_configuration  = lookup(each.value, "server_side_encryption_configuration", {})
  object_lock_configuration             = lookup(each.value, "object_lock_configuration", {})
  block_public_acls                     = lookup(each.value, "block_public_acls", false)
  block_public_policy                   = lookup(each.value, "block_public_policy", false)
  ignore_public_acls                    = lookup(each.value, "ignore_public_acls", false)
  restrict_public_buckets               = lookup(each.value, "restrict_public_buckets", false)
}
