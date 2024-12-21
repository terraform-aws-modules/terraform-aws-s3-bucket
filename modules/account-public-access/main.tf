resource "aws_s3_account_public_access_block" "this" {
  count = var.create ? 1 : 0

  account_id = var.account_id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}
