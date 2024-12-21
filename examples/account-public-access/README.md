# S3 account-level Public Access Block

Configuration in this directory creates S3 account-level Public Access Block.

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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.70 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 2.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_account_public_access"></a> [account\_public\_access](#module\_account\_public\_access) | ../../modules/account-public-access | n/a |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_s3_account_public_access_block_id"></a> [s3\_account\_public\_access\_block\_id](#output\_s3\_account\_public\_access\_block\_id) | AWS account ID |
<!-- END_TF_DOCS -->
