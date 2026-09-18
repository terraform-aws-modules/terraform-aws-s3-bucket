# S3 directory bucket

Configuration in this directory creates S3 directory bucket and related resources.

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
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.44 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.44 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_complete"></a> [complete](#module\_complete) | ../../ | n/a |
| <a name="module_inventory_destination_bucket"></a> [inventory\_destination\_bucket](#module\_inventory\_destination\_bucket) | ../../ | n/a |
| <a name="module_kms"></a> [kms](#module\_kms) | terraform-aws-modules/kms/aws | ~> 4.0 |
| <a name="module_simple"></a> [simple](#module\_simple) | ../../ | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.destination_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_directory_bucket_arn"></a> [directory\_bucket\_arn](#output\_directory\_bucket\_arn) | ARN of the directory bucket |
| <a name="output_directory_bucket_name"></a> [directory\_bucket\_name](#output\_directory\_bucket\_name) | Name of the directory bucket |
<!-- END_TF_DOCS -->
