# S3 bucket object

Configuration in this directory creates S3 bucket objects with different configurations.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.50 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.50 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_object"></a> [object](#module\_object) | ../../modules/object | n/a |
| <a name="module_object_complete"></a> [object\_complete](#module\_object\_complete) | ../../modules/object | n/a |
| <a name="module_object_locked"></a> [object\_locked](#module\_object\_locked) | ../../modules/object | n/a |
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | ../../ | n/a |
| <a name="module_s3_bucket_with_object_lock"></a> [s3\_bucket\_with\_object\_lock](#module\_s3\_bucket\_with\_object\_lock) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [random_pet.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname. |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | The name of the bucket. |
| <a name="output_s3_bucket_object_etag"></a> [s3\_bucket\_object\_etag](#output\_s3\_bucket\_object\_etag) | The ETag generated for the object (an MD5 sum of the object content). |
| <a name="output_s3_bucket_object_id"></a> [s3\_bucket\_object\_id](#output\_s3\_bucket\_object\_id) | The key of S3 object |
| <a name="output_s3_bucket_object_version_id"></a> [s3\_bucket\_object\_version\_id](#output\_s3\_bucket\_object\_version\_id) | A unique version ID value for the object, if bucket versioning is enabled. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
