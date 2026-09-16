# Amazon S3 Files File System

Creates an Amazon S3 Files file system on a general purpose bucket, with its IAM role, mount targets, access points, file system policy and synchronization configuration.

The bucket must have versioning enabled.

> [!IMPORTANT]
> Pass the versioning resource's own status to `bucket_versioning_status`, as in
> `aws_s3_bucket_versioning.this.versioning_configuration[0].status`. That reference is what makes the
> file system wait for versioning on create, and be deleted before versioning is suspended on destroy.
> A literal `"Enabled"` passes the check and leaves no such ordering, so a destroy can fail with
> `BucketHasS3FileSystemAttached`. This applies only when calling this module directly. The root
> module's `file_systems` input passes the reference for you.

```hcl
module "file_system" {
  source = "terraform-aws-modules/s3-bucket/aws//modules/file-system"

  name                     = "training"
  bucket_arn               = aws_s3_bucket.this.arn
  bucket_versioning_status = aws_s3_bucket_versioning.this.versioning_configuration[0].status

  security_group_vpc_id = "vpc-1234556abcdef"
  security_group_ingress_rules = {
    clients = {
      referenced_security_group_id = "sg-1234556abcdef"
    }
  }

  mount_targets = {
    "eu-west-1a" = { subnet_id = "subnet-1234556abcdef" }
  }
}
```

When the bucket is created by the root module, use its `file_systems` input instead, which calls this module for each entry.

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

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_s3files_access_point.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3files_access_point) | resource |
| [aws_s3files_file_system.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3files_file_system) | resource |
| [aws_s3files_file_system_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3files_file_system_policy) | resource |
| [aws_s3files_mount_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3files_mount_target) | resource |
| [aws_s3files_synchronization_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3files_synchronization_configuration) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_service_principal.elasticfilesystem](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/service_principal) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_accept_bucket_warning"></a> [accept\_bucket\_warning](#input\_accept\_bucket\_warning) | Whether to acknowledge the warning AWS raises when the bucket holds enough objects that renaming a prefix is slow | `bool` | `null` | no |
| <a name="input_access_points"></a> [access\_points](#input\_access\_points) | Map of access points to create on the file system. An access point cannot be edited, so any change replaces it | <pre>map(object({<br/>    name = optional(string) # Will fall back to map key<br/>    tags = optional(map(string))<br/><br/>    posix_user = optional(object({<br/>      gid            = number<br/>      uid            = number<br/>      secondary_gids = optional(list(number))<br/>    }))<br/>    root_directory = optional(object({<br/>      path = optional(string)<br/>      creation_permissions = optional(object({<br/>        owner_gid   = number<br/>        owner_uid   = number<br/>        permissions = string<br/>      }))<br/>    }))<br/><br/>    timeouts = optional(object({<br/>      create = optional(string)<br/>      delete = optional(string)<br/>    }))<br/><br/>    # A principal listed here is denied every other way into this file system, including mounting without an access point<br/>    read_access_arns       = optional(list(string))<br/>    read_write_access_arns = optional(list(string))<br/>  }))</pre> | `{}` | no |
| <a name="input_bucket_arn"></a> [bucket\_arn](#input\_bucket\_arn) | ARN of the general purpose bucket the file system is created on | `string` | n/a | yes |
| <a name="input_bucket_versioning_status"></a> [bucket\_versioning\_status](#input\_bucket\_versioning\_status) | Versioning status of the bucket. Pass the versioning resource's own attribute, which makes the file system wait for versioning on create and be deleted before it is suspended on destroy | `string` | n/a | yes |
| <a name="input_create"></a> [create](#input\_create) | Whether to create the file system and its associated resources | `bool` | `true` | no |
| <a name="input_create_iam_role"></a> [create\_iam\_role](#input\_create\_iam\_role) | Whether to create an IAM role for the file system | `bool` | `true` | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | Whether to create a security group for the mount targets | `bool` | `true` | no |
| <a name="input_iam_role_arn"></a> [iam\_role\_arn](#input\_iam\_role\_arn) | ARN of an existing IAM role for the file system to assume. Used when `create_iam_role` is `false` | `string` | `null` | no |
| <a name="input_iam_role_description"></a> [iam\_role\_description](#input\_iam\_role\_description) | Description of the IAM role created | `string` | `null` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name of the IAM role created. Falls back to the file system name suffixed with `-s3files` | `string` | `null` | no |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | Path of the IAM role created | `string` | `null` | no |
| <a name="input_iam_role_permissions_boundary"></a> [iam\_role\_permissions\_boundary](#input\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM role created | `string` | `null` | no |
| <a name="input_iam_role_tags"></a> [iam\_role\_tags](#input\_iam\_role\_tags) | Additional tags for the IAM role created | `map(string)` | `null` | no |
| <a name="input_iam_role_use_name_prefix"></a> [iam\_role\_use\_name\_prefix](#input\_iam\_role\_use\_name\_prefix) | Whether to use the IAM role name as a prefix | `bool` | `true` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | ID of the KMS key used to encrypt the file system. An AWS owned key is used when not set | `string` | `null` | no |
| <a name="input_mount_targets"></a> [mount\_targets](#input\_mount\_targets) | Map of mount targets to create for the file system, keyed by a value known at plan time such as the Availability Zone. One per Availability Zone at most | <pre>map(object({<br/>    subnet_id       = string<br/>    ip_address_type = optional(string)<br/>    ipv4_address    = optional(string)<br/>    ipv6_address    = optional(string)<br/>    security_groups = optional(list(string))<br/>    timeouts = optional(object({<br/>      create = optional(string)<br/>      delete = optional(string)<br/>      update = optional(string)<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the file system, used for the `Name` tag and as the prefix of any names this module generates | `string` | `null` | no |
| <a name="input_override_policy_documents"></a> [override\_policy\_documents](#input\_override\_policy\_documents) | List of IAM policy documents that are merged together into the file system policy. In merging, statements with non-blank `sid`s will override statements with the same `sid` | `list(string)` | `[]` | no |
| <a name="input_policy_statements"></a> [policy\_statements](#input\_policy\_statements) | List of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) to add to the file system policy | <pre>list(object({<br/>    sid           = optional(string)<br/>    actions       = optional(list(string))<br/>    not_actions   = optional(list(string))<br/>    effect        = optional(string)<br/>    resources     = optional(list(string))<br/>    not_resources = optional(list(string))<br/>    principals = optional(list(object({<br/>      type        = string<br/>      identifiers = list(string)<br/>    })))<br/>    not_principals = optional(list(object({<br/>      type        = string<br/>      identifiers = list(string)<br/>    })))<br/>    conditions = optional(list(object({<br/>      test     = string<br/>      values   = list(string)<br/>      variable = string<br/>    })))<br/>  }))</pre> | `null` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix within the bucket the file system is scoped to. The whole bucket when not set | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration | `string` | `null` | no |
| <a name="input_security_group_description"></a> [security\_group\_description](#input\_security\_group\_description) | Description of the security group created | `string` | `null` | no |
| <a name="input_security_group_egress_rules"></a> [security\_group\_egress\_rules](#input\_security\_group\_egress\_rules) | Map of egress rules to add to the security group | <pre>map(object({<br/>    name = optional(string)<br/><br/>    cidr_ipv4                    = optional(string)<br/>    cidr_ipv6                    = optional(string)<br/>    description                  = optional(string)<br/>    from_port                    = optional(number)<br/>    ip_protocol                  = string<br/>    prefix_list_id               = optional(string)<br/>    referenced_security_group_id = optional(string)<br/>    tags                         = optional(map(string))<br/>    to_port                      = optional(number)<br/>  }))</pre> | `{}` | no |
| <a name="input_security_group_ingress_rules"></a> [security\_group\_ingress\_rules](#input\_security\_group\_ingress\_rules) | Map of ingress rules to add to the security group. Clients reach a mount target over TCP 2049 | <pre>map(object({<br/>    name = optional(string)<br/><br/>    cidr_ipv4                    = optional(string)<br/>    cidr_ipv6                    = optional(string)<br/>    description                  = optional(string)<br/>    from_port                    = optional(number, 2049)<br/>    ip_protocol                  = optional(string, "tcp")<br/>    prefix_list_id               = optional(string)<br/>    referenced_security_group_id = optional(string)<br/>    tags                         = optional(map(string))<br/>    to_port                      = optional(number, 2049)<br/>  }))</pre> | `{}` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | Name of the security group created. Falls back to the file system name suffixed with `-s3files` | `string` | `null` | no |
| <a name="input_security_group_tags"></a> [security\_group\_tags](#input\_security\_group\_tags) | Additional tags for the security group created | `map(string)` | `null` | no |
| <a name="input_security_group_use_name_prefix"></a> [security\_group\_use\_name\_prefix](#input\_security\_group\_use\_name\_prefix) | Whether to use the security group name as a prefix | `bool` | `true` | no |
| <a name="input_security_group_vpc_id"></a> [security\_group\_vpc\_id](#input\_security\_group\_vpc\_id) | ID of the VPC the security group is created in | `string` | `null` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | Security groups for the mount targets. Replaces the security group this module would otherwise create | `list(string)` | `null` | no |
| <a name="input_source_policy_documents"></a> [source\_policy\_documents](#input\_source\_policy\_documents) | List of IAM policy documents that are merged together into the file system policy. Statements must have unique `sid`s | `list(string)` | `[]` | no |
| <a name="input_synchronization_configuration"></a> [synchronization\_configuration](#input\_synchronization\_configuration) | Synchronization configuration for the file system | <pre>object({<br/>    import_data_rule = list(object({<br/>      prefix         = string<br/>      size_less_than = number<br/>      trigger        = string<br/>    }))<br/>    # Required: the API takes exactly one expiration rule with every synchronization configuration<br/>    expiration_data_rule = object({<br/>      days_after_last_access = number<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resource tags | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Create and delete timeouts for the file system | <pre>object({<br/>    create = optional(string)<br/>    delete = optional(string)<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_access_points"></a> [access\_points](#output\_access\_points) | Map of access points created and their attributes |
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the file system |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | ARN of the IAM role the file system assumes, whether created here or supplied by the caller |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | Name of the IAM role created |
| <a name="output_iam_role_unique_id"></a> [iam\_role\_unique\_id](#output\_iam\_role\_unique\_id) | Unique ID of the IAM role created |
| <a name="output_id"></a> [id](#output\_id) | ID of the file system |
| <a name="output_mount_targets"></a> [mount\_targets](#output\_mount\_targets) | Map of mount targets created and their attributes |
| <a name="output_name"></a> [name](#output\_name) | Name of the file system |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | ARN of the security group created |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the security group created |
| <a name="output_status"></a> [status](#output\_status) | Status of the file system |
<!-- END_TF_DOCS -->
