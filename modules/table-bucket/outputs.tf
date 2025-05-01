output "s3_table_bucket_arn" {
  description = "ARN of the table bucket."
  value       = try(aws_s3tables_table_bucket.this[0].arn, null)
}

output "s3_table_bucket_created_at" {
  description = "Date and time when the bucket was created."
  value       = try(aws_s3tables_table_bucket.this[0].created_at, null)
}

output "s3_table_bucket_owner_account_id" {
  description = "Account ID of the account that owns the table bucket."
  value       = try(aws_s3tables_table_bucket.this[0].owner_account_id, null)
}

output "s3_table_arns" {
  description = "The table ARNs."
  value       = { for k, v in aws_s3tables_table.this : k => v.arn }
}

output "s3_table_created_at" {
  description = "Dates and times when the tables were created."
  value       = { for k, v in aws_s3tables_table.this : k => v.created_at }
}

output "s3_table_created_by" {
  description = "Account IDs of the accounts that created the tables"
  value       = { for k, v in aws_s3tables_table.this : k => v.created_by }
}

output "s3_table_metadata_locations" {
  description = "Locations of table metadata."
  value       = { for k, v in aws_s3tables_table.this : k => v.metadata_location }
}

output "s3_table_modified_at" {
  description = "Dates and times when the tables was last modified."
  value       = { for k, v in aws_s3tables_table.this : k => v.modified_at }
}

output "s3_table_modified_by" {
  description = "Account IDs of the accounts that last modified the tables."
  value       = { for k, v in aws_s3tables_table.this : k => v.modified_by }
}

output "s3_table_owner_account_ids" {
  description = "Account IDs of the accounts that owns the tables."
  value       = { for k, v in aws_s3tables_table.this : k => v.owner_account_id }
}

output "s3_table_types" {
  description = "Types of the tables. One of customer or aws."
  value       = { for k, v in aws_s3tables_table.this : k => v.type }
}

output "s3_table_version_tokens" {
  description = "Identifiers for the current version of table data."
  value       = { for k, v in aws_s3tables_table.this : k => v.version_token }
}

output "s3_table_warehouse_locations" {
  description = "S3 URIs pointing to the S3 Bucket that contains the table data."
  value       = { for k, v in aws_s3tables_table.this : k => v.warehouse_location }
}
