# S3 Vectors

This example demonstrates how to create [Amazon S3 Vectors](https://aws.amazon.com/s3/features/vectors/) vector buckets with bucket policies and vector indexes.

It creates a vector bucket with KMS encryption and an IAM bucket policy granting read and write access, and a second vector bucket with an associated vector index configured for 1536 dimensional embeddings using the cosine distance metric.

## Usage

To run this example you need to execute:

```bash
terraform init
terraform plan
terraform apply
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.42 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.42 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_disabled"></a> [disabled](#module\_disabled) | ../../modules/vectors | n/a |
| <a name="module_kms"></a> [kms](#module\_kms) | terraform-aws-modules/kms/aws | ~> 4.0 |
| <a name="module_vector_bucket"></a> [vector\_bucket](#module\_vector\_bucket) | ../../modules/vectors | n/a |
| <a name="module_vector_bucket_with_index"></a> [vector\_bucket\_with\_index](#module\_vector\_bucket\_with\_index) | ../../modules/vectors | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.vector_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_index_arns"></a> [index\_arns](#output\_index\_arns) | ARNs of the vector indexes |
| <a name="output_index_creation_times"></a> [index\_creation\_times](#output\_index\_creation\_times) | Date and time when the vector indexes were created |
| <a name="output_vector_bucket_arn"></a> [vector\_bucket\_arn](#output\_vector\_bucket\_arn) | ARN of the S3 Vectors vector bucket |
| <a name="output_vector_bucket_name"></a> [vector\_bucket\_name](#output\_vector\_bucket\_name) | Name of the S3 Vectors vector bucket |
| <a name="output_vector_bucket_with_index_arn"></a> [vector\_bucket\_with\_index\_arn](#output\_vector\_bucket\_with\_index\_arn) | ARN of the S3 Vectors vector bucket with index |
<!-- END_TF_DOCS -->
