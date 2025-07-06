# S3 Table Bucket

Configuration in this directory creates S3 table bucket with bucket policy and S3 Tables with table policies.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.2 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.2 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kms"></a> [kms](#module\_kms) | terraform-aws-modules/kms/aws | ~> 3.0 |
| <a name="module_table_bucket"></a> [table\_bucket](#module\_table\_bucket) | ../../modules/table-bucket | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_s3tables_namespace.namespace](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3tables_namespace) | resource |
| [random_pet.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_owner_account_id"></a> [owner\_account\_id](#output\_owner\_account\_id) | Account ID of the account that owns the table bucket. |
| <a name="output_s3_table_arns"></a> [s3\_table\_arns](#output\_s3\_table\_arns) | The table ARNs. |
| <a name="output_s3_table_bucket_arn"></a> [s3\_table\_bucket\_arn](#output\_s3\_table\_bucket\_arn) | ARN of the table bucket. |
| <a name="output_s3_table_bucket_created_at"></a> [s3\_table\_bucket\_created\_at](#output\_s3\_table\_bucket\_created\_at) | Date and time when the bucket was created. |
| <a name="output_s3_table_created_at"></a> [s3\_table\_created\_at](#output\_s3\_table\_created\_at) | Dates and times when the tables were created. |
| <a name="output_s3_table_created_by"></a> [s3\_table\_created\_by](#output\_s3\_table\_created\_by) | Account IDs of the accounts that created the tables |
| <a name="output_s3_table_metadata_locations"></a> [s3\_table\_metadata\_locations](#output\_s3\_table\_metadata\_locations) | Locations of table metadata. |
| <a name="output_s3_table_modified_at"></a> [s3\_table\_modified\_at](#output\_s3\_table\_modified\_at) | Dates and times when the tables was last modified. |
| <a name="output_s3_table_modified_by"></a> [s3\_table\_modified\_by](#output\_s3\_table\_modified\_by) | Account IDs of the accounts that last modified the tables. |
| <a name="output_s3_table_owner_account_ids"></a> [s3\_table\_owner\_account\_ids](#output\_s3\_table\_owner\_account\_ids) | Account IDs of the accounts that owns the tables. |
| <a name="output_s3_table_types"></a> [s3\_table\_types](#output\_s3\_table\_types) | Types of the tables. One of customer or aws. |
| <a name="output_s3_table_version_tokens"></a> [s3\_table\_version\_tokens](#output\_s3\_table\_version\_tokens) | Identifiers for the current version of table data. |
| <a name="output_s3_table_warehouse_locations"></a> [s3\_table\_warehouse\_locations](#output\_s3\_table\_warehouse\_locations) | S3 URIs pointing to the S3 Bucket that contains the table data. |
<!-- END_TF_DOCS -->
