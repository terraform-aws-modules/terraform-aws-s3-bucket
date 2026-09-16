# S3 account-level Public Access Block

Configuration in this directory creates S3 account-level Public Access Block.

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
| <a name="module_account_public_access"></a> [account\_public\_access](#module\_account\_public\_access) | ../../modules/account-public-access | n/a |
| <a name="module_disabled"></a> [disabled](#module\_disabled) | ../../modules/account-public-access | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_s3_account_public_access_block_id"></a> [s3\_account\_public\_access\_block\_id](#output\_s3\_account\_public\_access\_block\_id) | AWS account ID |
<!-- END_TF_DOCS -->
