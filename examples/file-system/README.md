# S3 file system

Configuration in this directory creates an S3 bucket with two Amazon S3 Files file systems scoped to separate prefixes of the same bucket. The `training` file system preloads small files for a machine learning training workload and uses the module's shared security group. The `agents` file system imports metadata only, uses its own security group, and exposes an access point for an IAM role.

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
| <a name="module_agents_security_group"></a> [agents\_security\_group](#module\_agents\_security\_group) | terraform-aws-modules/security-group/aws | ~> 6.0 |
| <a name="module_client_role"></a> [client\_role](#module\_client\_role) | terraform-aws-modules/iam/aws//modules/iam-role | ~> 6.0 |
| <a name="module_client_security_group"></a> [client\_security\_group](#module\_client\_security\_group) | terraform-aws-modules/security-group/aws | ~> 6.0 |
| <a name="module_disabled"></a> [disabled](#module\_disabled) | ../../ | n/a |
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | ../../ | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 6.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_file_system_access_points"></a> [file\_system\_access\_points](#output\_file\_system\_access\_points) | Map of file system access points created and their attributes |
| <a name="output_file_system_iam_roles"></a> [file\_system\_iam\_roles](#output\_file\_system\_iam\_roles) | Map of IAM roles created for the file systems and their attributes |
| <a name="output_file_system_mount_targets"></a> [file\_system\_mount\_targets](#output\_file\_system\_mount\_targets) | Map of file system mount targets created and their attributes |
| <a name="output_file_system_security_group_arn"></a> [file\_system\_security\_group\_arn](#output\_file\_system\_security\_group\_arn) | ARN of the file system security group |
| <a name="output_file_system_security_group_id"></a> [file\_system\_security\_group\_id](#output\_file\_system\_security\_group\_id) | ID of the file system security group |
| <a name="output_file_systems"></a> [file\_systems](#output\_file\_systems) | Map of file systems created and their attributes |
<!-- END_TF_DOCS -->
