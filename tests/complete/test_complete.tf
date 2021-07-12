locals {
  bucket_name = "s3-bucket-${random_pet.this.id}"
}

data "aws_canonical_user_id" "current" {}

resource "random_pet" "this" {
  length = 2
}

module "complete" {
  source = "../../"

  bucket                                = "logs-${random_pet.this.id}"
  acl                                   = "log-delivery-write"
  force_destroy                         = true
  attach_elb_log_delivery_policy        = true
  attach_deny_insecure_transport_policy = true
}
