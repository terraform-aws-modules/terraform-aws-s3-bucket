output "s3_table_bucket_arn" {
  description = "ARN of the table bucket."
  value       = module.table_bucket.s3_table_bucket_arn
}

output "s3_table_bucket_created_at" {
  description = "Date and time when the bucket was created."
  value       = module.table_bucket.s3_table_bucket_created_at
}

output "owner_account_id" {
  description = "Account ID of the account that owns the table bucket."
  value       = module.table_bucket.s3_table_bucket_owner_account_id
}

output "s3_table_arns" {
  description = "The table ARNs."
  value       = module.table_bucket.s3_table_arns
}

output "s3_table_created_at" {
  description = "Dates and times when the tables were created."
  value       = module.table_bucket.s3_table_created_at
}

output "s3_table_created_by" {
  description = "Account IDs of the accounts that created the tables"
  value       = module.table_bucket.s3_table_created_by
}

output "s3_table_metadata_locations" {
  description = "Locations of table metadata."
  value       = module.table_bucket.s3_table_metadata_locations
}

output "s3_table_modified_at" {
  description = "Dates and times when the tables was last modified."
  value       = module.table_bucket.s3_table_modified_at
}

output "s3_table_modified_by" {
  description = "Account IDs of the accounts that last modified the tables."
  value       = module.table_bucket.s3_table_modified_by
}

output "s3_table_owner_account_ids" {
  description = "Account IDs of the accounts that owns the tables."
  value       = module.table_bucket.s3_table_owner_account_ids
}

output "s3_table_types" {
  description = "Types of the tables. One of customer or aws."
  value       = module.table_bucket.s3_table_types
}

output "s3_table_version_tokens" {
  description = "Identifiers for the current version of table data."
  value       = module.table_bucket.s3_table_version_tokens
}

output "s3_table_warehouse_locations" {
  description = "S3 URIs pointing to the S3 Bucket that contains the table data."
  value       = module.table_bucket.s3_table_warehouse_locations
}
