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
| <a name="module_external_bucket"></a> [external\_bucket](#module\_external\_bucket) | ../../ | n/a |
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | ../../ | n/a |
| <a name="module_s3_file_system"></a> [s3\_file\_system](#module\_s3\_file\_system) | ../../modules/file-system | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 6.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_iam_policy_document.no_root_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_external_file_system_arn"></a> [external\_file\_system\_arn](#output\_external\_file\_system\_arn) | ARN of the file system created on the bucket this module does not manage |
| <a name="output_external_file_system_id"></a> [external\_file\_system\_id](#output\_external\_file\_system\_id) | ID of the file system created on the bucket this module does not manage |
| <a name="output_external_file_system_security_group_id"></a> [external\_file\_system\_security\_group\_id](#output\_external\_file\_system\_security\_group\_id) | ID of the security group created for that file system's mount targets |
| <a name="output_file_system_access_points"></a> [file\_system\_access\_points](#output\_file\_system\_access\_points) | Map of file system access points created and their attributes |
| <a name="output_file_system_iam_roles"></a> [file\_system\_iam\_roles](#output\_file\_system\_iam\_roles) | Map of IAM roles created for the file systems, with their ARN, name and unique ID |
| <a name="output_file_system_mount_targets"></a> [file\_system\_mount\_targets](#output\_file\_system\_mount\_targets) | Map of file system mount targets created and their attributes |
| <a name="output_file_system_security_group_arns"></a> [file\_system\_security\_group\_arns](#output\_file\_system\_security\_group\_arns) | Map of the security group created for each file system, by ARN |
| <a name="output_file_system_security_group_ids"></a> [file\_system\_security\_group\_ids](#output\_file\_system\_security\_group\_ids) | Map of the security group created for each file system, by ID |
| <a name="output_file_systems"></a> [file\_systems](#output\_file\_systems) | Map of file systems created and their attributes |
<!-- END_TF_DOCS -->
