# AWS S3 Files Submodule

Terraform submodule for managing [Amazon S3 Files](https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-files.html) resources — a feature released in April 2026 that allows an S3 bucket to be mounted as an NFS-style file system from inside a VPC.

This submodule creates:

- `aws_s3files_file_system` — attaches the S3 Files file system to a versioned S3 bucket
- `aws_s3files_mount_target` — one mount target per subnet, enabling multi-AZ deployments
- `aws_s3files_file_system_policy` — a resource-based policy controlling NFS client access
- `aws_s3files_access_point` — optional per-client access points with isolated POSIX identity and root directory

## Architecture

The submodule is intentionally **decoupled** from the root `terraform-aws-s3-bucket` module.  It accepts the ARN of an _existing_ S3 bucket via `bucket_arn` rather than creating one itself, so teams can compose it with any bucket provisioning approach.

### Prerequisites

| Requirement | Reason |
|---|---|
| S3 bucket with versioning enabled | The S3 Files API rejects buckets that do not have versioning enabled |
| IAM role with S3 permissions | Passed via `role_arn`; the service uses this role to read/write objects on behalf of NFS clients |
| VPC, subnets, and security groups | Mount targets are VPC-attached ENIs; at least one subnet is required |
| AWS provider `>= 6.39` | The `aws_s3files_*` resources were introduced in this provider version |

### Destroy ordering

Because the S3 Files file system holds a reference to the S3 bucket, attempting to destroy the bucket before the file system is detached results in a `409 BucketHasS3FileSystemAttached` error.  When managing both resources in the same Terraform configuration, add `module.s3_bucket` to `depends_on` on the `module "s3_files"` block:

```hcl
module "s3_files" {
  source = "terraform-aws-modules/s3-bucket/aws//modules/s3-files"

  # ...

  depends_on = [
    aws_iam_role_policy.s3_files_bucket_access,
    module.s3_bucket,   # ensures file system is destroyed before the bucket
  ]
}
```

Terraform inverts `depends_on` during destroy, guaranteeing that all S3 Files resources are torn down before the bucket is deleted.

## Usage

### Basic

Minimum viable configuration — creates one mount target per subnet with a secure auto-generated file system policy (VPC-scoped, account-root principal):

```hcl
module "s3_files" {
  source = "terraform-aws-modules/s3-bucket/aws//modules/s3-files"

  bucket_arn = "arn:aws:s3:::my-versioned-bucket"
  role_arn = aws_iam_role.s3_files.arn

  vpc_id     = "vpc-0a1b2c3d4e5f"
  subnet_ids = ["subnet-aaa111", "subnet-bbb222"]

  security_group_ids = [aws_security_group.nfs.id]

  tags = {
    Environment = "production"
  }
}
```

### Advanced — static IPs and a custom file system policy

Pin static IPv4 addresses to specific mount targets and provide a fully custom resource-based policy:

```hcl
module "s3_files" {
  source = "terraform-aws-modules/s3-bucket/aws//modules/s3-files"

  bucket_arn = "arn:aws:s3:::my-versioned-bucket"
  role_arn = aws_iam_role.s3_files.arn

  vpc_id     = "vpc-0a1b2c3d4e5f"
  subnet_ids = ["subnet-aaa111", "subnet-bbb222"]

  security_group_ids = [aws_security_group.nfs.id]

  ip_address_type = "ipv4"
  mount_target_ipv4_addresses = {
    "subnet-aaa111" = "10.0.1.50"
    "subnet-bbb222" = "10.0.2.50"
  }

  # Provide a hand-crafted policy; module will NOT generate the default policy
  file_system_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowSpecificRoleClientMount"
        Effect    = "Allow"
        Principal = { AWS = aws_iam_role.nfs_client.arn }
        Action    = "s3files:ClientMount"
        Resource  = "*"
        Condition = {
          StringEquals = { "aws:SourceVpc" = "vpc-0a1b2c3d4e5f" }
        }
      }
    ]
  })

  tags = {
    Environment = "production"
  }
}
```

### Access points

Access points give each NFS client an isolated POSIX identity and, optionally, a dedicated root directory with auto-created permissions.  Pass a map to `access_points`; each key becomes the map key in the `s3_files_access_points` output:

```hcl
module "s3_files" {
  source = "terraform-aws-modules/s3-bucket/aws//modules/s3-files"

  bucket_arn = "arn:aws:s3:::my-versioned-bucket"
  role_arn = aws_iam_role.s3_files.arn

  vpc_id             = "vpc-0a1b2c3d4e5f"
  subnet_ids         = ["subnet-aaa111", "subnet-bbb222"]
  security_group_ids = [aws_security_group.nfs.id]

  access_points = {
    # Minimal — POSIX identity only, no dedicated root directory
    "app-readonly" = {
      posix_user = {
        uid = 1001
        gid = 1001
      }
    }

    # Full — dedicated root directory created with explicit permissions
    "app-readwrite" = {
      posix_user = {
        uid            = 1000
        gid            = 1000
        secondary_gids = [2000, 3000]
      }
      root_directory = {
        path = "/app-data"
        creation_permissions = {
          owner_uid   = 1000
          owner_gid   = 1000
          permissions = "0755"
        }
      }
    }
  }

  tags = {
    Environment = "production"
  }
}
```

The `s3_files_access_points` output returns a map of `{ id, arn, name }` for each created access point.

### Disable resource creation

Set `create = false` to skip all resource creation while keeping the module call in place (useful for conditional deployments or feature flags):

```hcl
module "s3_files" {
  source = "terraform-aws-modules/s3-bucket/aws//modules/s3-files"

  create = false
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.42 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.42 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3files_access_point.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3files_access_point) | resource |
| [aws_s3files_file_system.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3files_file_system) | resource |
| [aws_s3files_file_system_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3files_file_system_policy) | resource |
| [aws_s3files_mount_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3files_mount_target) | resource |
| [aws_s3files_synchronization_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3files_synchronization_configuration) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accept_bucket_warning"></a> [accept\_bucket\_warning](#input\_accept\_bucket\_warning) | Whether to acknowledge and accept bucket warnings during file system creation | `bool` | `null` | no |
| <a name="input_access_points"></a> [access\_points](#input\_access\_points) | Map of S3 Files access point configurations to create | <pre>map(object({<br/>    tags = optional(map(string), {})<br/>    posix_user = object({<br/>      uid            = number<br/>      gid            = number<br/>      secondary_gids = optional(list(number), null)<br/>    })<br/>    root_directory = optional(object({<br/>      path = optional(string, null)<br/>      creation_permissions = optional(object({<br/>        owner_uid   = number<br/>        owner_gid   = number<br/>        permissions = string<br/>      }), null)<br/>    }), null)<br/>  }))</pre> | `{}` | no |
| <a name="input_bucket_arn"></a> [bucket\_arn](#input\_bucket\_arn) | ARN of the S3 bucket | `string` | `null` | no |
| <a name="input_create"></a> [create](#input\_create) | Whether to create this resource or not? | `bool` | `true` | no |
| <a name="input_create_file_system_policy"></a> [create\_file\_system\_policy](#input\_create\_file\_system\_policy) | Whether to create an s3 files file system policy | `bool` | `true` | no |
| <a name="input_file_system_policy"></a> [file\_system\_policy](#input\_file\_system\_policy) | Amazon Web Services resource-based policy document in JSON format for the file system. If null, a default policy allowing account-root mount scoped to the provided VPC is created | `string` | `null` | no |
| <a name="input_ip_address_type"></a> [ip\_address\_type](#input\_ip\_address\_type) | IP address type for mount targets | `string` | `null` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | KMS key ID for encrypting data in the file system | `string` | `null` | no |
| <a name="input_mount_target_ipv4_addresses"></a> [mount\_target\_ipv4\_addresses](#input\_mount\_target\_ipv4\_addresses) | Map of explicit IPv4 addresses for mount targets keyed by subnet ID | `map(string)` | `{}` | no |
| <a name="input_mount_target_ipv6_addresses"></a> [mount\_target\_ipv6\_addresses](#input\_mount\_target\_ipv6\_addresses) | Map of explicit IPv6 addresses for mount targets keyed by subnet ID | `map(string)` | `{}` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | S3 bucket prefix to scope the file system | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where the resource(s) will be managed. Defaults to the region set in the provider configuration | `string` | `null` | no |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | IAM role ARN used by S3 Files to access the S3 bucket | `string` | `null` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs to attach to each mount target | `list(string)` | `[]` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs where mount targets will be created | `list(string)` | `[]` | no |
| <a name="input_synchronization_expiration_data_rule"></a> [synchronization\_expiration\_data\_rule](#input\_synchronization\_expiration\_data\_rule) | Expiration rule for S3 Files synchronization. | <pre>object({<br/>    days_after_last_access = number<br/>  })</pre> | <pre>{<br/>  "days_after_last_access": 30<br/>}</pre> | no |
| <a name="input_synchronization_import_data_rules"></a> [synchronization\_import\_data\_rules](#input\_synchronization\_import\_data\_rules) | Import data rules for S3 Files synchronization. Note: size\_less\_than is in bytes (131072 bytes = 128KB). | <pre>list(object({<br/>    prefix         = string<br/>    size_less_than = number<br/>    trigger        = string<br/>  }))</pre> | <pre>[<br/>  {<br/>    "prefix": "",<br/>    "size_less_than": 131072,<br/>    "trigger": "ON_DIRECTORY_FIRST_ACCESS"<br/>  }<br/>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resource tags | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where mount targets will be created | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_s3_files_access_points"></a> [s3\_files\_access\_points](#output\_s3\_files\_access\_points) | Map of S3 Files access points, keyed by the user-defined map key, with id, arn, and name attributes |
| <a name="output_s3_files_file_system_arn"></a> [s3\_files\_file\_system\_arn](#output\_s3\_files\_file\_system\_arn) | ARN of the S3 Files file system |
| <a name="output_s3_files_file_system_id"></a> [s3\_files\_file\_system\_id](#output\_s3\_files\_file\_system\_id) | Identifier of the S3 Files file system |
| <a name="output_s3_files_mount_target_network_interface_ids"></a> [s3\_files\_mount\_target\_network\_interface\_ids](#output\_s3\_files\_mount\_target\_network\_interface\_ids) | List of mount target network interface IDs |
<!-- END_TF_DOCS -->
