################################################################################
# Vector Bucket
################################################################################

output "vector_bucket_arn" {
  description = "ARN of the S3 Vectors vector bucket"
  value       = try(aws_s3vectors_vector_bucket.this[0].vector_bucket_arn, null)
}

output "vector_bucket_name" {
  description = "Name of the S3 Vectors vector bucket"
  value       = try(aws_s3vectors_vector_bucket.this[0].vector_bucket_name, null)
}

output "creation_time" {
  description = "Date and time when the vector bucket was created"
  value       = try(aws_s3vectors_vector_bucket.this[0].creation_time, null)
}

################################################################################
# Vector Indexes
################################################################################

output "index_arns" {
  description = "ARNs of the vector indexes"
  value       = { for k, v in aws_s3vectors_index.this : k => v.index_arn }
}

output "index_creation_times" {
  description = "Date and time when the vector indexes were created"
  value       = { for k, v in aws_s3vectors_index.this : k => v.creation_time }
}
