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
| terraform | >= 0.12.26 |
| aws | >= 3.0 |
| null | >= 2 |
| random | >= 2 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.0 |
| random | >= 2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| object | ../../modules/object |  |
| object_complete | ../../modules/object |  |
| object_locked | ../../modules/object |  |
| s3_bucket | ../../ |  |
| s3_bucket_with_object_lock | ../../ |  |

## Resources

| Name |
|------|
| [aws_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) |
| [random_pet](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) |

## Inputs

No input.

## Outputs

| Name | Description |
|------|-------------|
| this\_s3\_bucket\_arn | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname. |
| this\_s3\_bucket\_id | The name of the bucket. |
| this\_s3\_bucket\_object\_etag | The ETag generated for the object (an MD5 sum of the object content). |
| this\_s3\_bucket\_object\_id | The key of S3 object |
| this\_s3\_bucket\_object\_version\_id | A unique version ID value for the object, if bucket versioning is enabled. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
