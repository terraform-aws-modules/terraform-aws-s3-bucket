################################################################################
# Vector Bucket
################################################################################

output "vector_bucket_arn" {
  description = "ARN of the S3 Vectors vector bucket"
  value       = module.vector_bucket.vector_bucket_arn
}

output "vector_bucket_name" {
  description = "Name of the S3 Vectors vector bucket"
  value       = module.vector_bucket.vector_bucket_name
}

################################################################################
# Vector Bucket with Index
################################################################################

output "vector_bucket_with_index_arn" {
  description = "ARN of the S3 Vectors vector bucket with index"
  value       = module.vector_bucket_with_index.vector_bucket_arn
}

output "index_arns" {
  description = "ARNs of the vector indexes"
  value       = module.vector_bucket_with_index.index_arn
}
