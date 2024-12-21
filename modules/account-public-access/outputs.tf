output "s3_account_public_access_block_id" {
  description = "AWS account ID"
  value       = try(aws_s3_account_public_access_block.this[0].id, "")
}
