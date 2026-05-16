# S3 Vectors Example

This example demonstrates how to create [Amazon S3 Vectors](https://aws.amazon.com/s3-vectors/) vector buckets with bucket policies and vector indexes.

## Resources Created

- **Vector bucket with policy** - A vector bucket with KMS encryption and an IAM bucket policy granting read/write access
- **Vector bucket with index** - A vector bucket with an associated vector index configured for 1536-dimensional embeddings using cosine distance metric

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Clean Up

```bash
terraform destroy
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.42 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.42 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kms"></a> [kms](#module\_kms) | terraform-aws-modules/kms/aws | ~> 3.0 |
| <a name="module_vector_bucket"></a> [vector\_bucket](#module\_vector\_bucket) | ../../modules/vectors | n/a |
| <a name="module_vector_bucket_with_index"></a> [vector\_bucket\_with\_index](#module\_vector\_bucket\_with\_index) | ../../modules/vectors | n/a |

## Resources

| Name | Type |
|------|------|
| [random_pet.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.vector_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_index_arns"></a> [index\_arns](#output\_index\_arns) | ARNs of the vector indexes |
| <a name="output_vector_bucket_arn"></a> [vector\_bucket\_arn](#output\_vector\_bucket\_arn) | ARN of the S3 Vectors vector bucket |
| <a name="output_vector_bucket_name"></a> [vector\_bucket\_name](#output\_vector\_bucket\_name) | Name of the S3 Vectors vector bucket |
| <a name="output_vector_bucket_with_index_arn"></a> [vector\_bucket\_with\_index\_arn](#output\_vector\_bucket\_with\_index\_arn) | ARN of the S3 Vectors vector bucket with index |
<!-- END_TF_DOCS -->
