# Upgrade from v2.x to v3.x

If you have any questions regarding this upgrade process, please consult the [`examples/`](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/master/examples) projects:

If you find a bug, please open an issue with supporting configuration to reproduce.

## List of backwards incompatible changes

- Terraform AWS provider minimum version is now `v4.5.0` in order to have forward compatibility with Terraform AWS provider `v4.x`. Using the latest version of `v4` is highly recommended, if possible.
- If you are using AWS provider `v3.75` the latest supported version of this module is `v3.0.1`
- Main group of changes is related to refactoring of `aws_s3_bucket` resource into several smaller resources. Read [`S3 bucket refactor` section in the official Terraform AWS Provider Version 4 Upgrade Guide](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/version-4-upgrade#s3-bucket-refactor) and [discussion around these changes](https://github.com/hashicorp/terraform-provider-aws/issues/23106).
- `modules/object`: Changed resource type from `aws_bucket_s3_object` to `aws_s3_object`. After upgrade, on the next apply, Terraform will recreate the object. If you prefer to not have Terraform recreate the object, import the object using `aws_s3_object`. [Read more](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object#import).

## Additional changes

### Added

- None

### Modified

- `acl` variable is set to `null` by default
- In addition to pseudo-boolean values like "Enabled", "Disabled", "Suspended", it is now possible to specify `true` or `false` in all such arguments (e.g. `versioning = { enabled = true }`).

### Variable and output changes

1. Removed variables:

  - None

2. Renamed variables:

  - None

3. Added variables:

  - `owner`
  - `expected_bucket_owner`

4. Removed outputs:

  - None

5. Renamed outputs:

`modules/object`:

  - `s3_bucket_object_id` -> `s3_object_id`
  - `s3_bucket_object_etag` -> `s3_object_etag`
  - `s3_bucket_object_version_id` -> `s3_object_version_id`

6. Added outputs:

  - None

## Upgrade Migrations

The following examples demonstrate some of the changes that users can elect to make to avoid any potential disruptions when upgrading.

### Before 2.x Example

See code in [`examples/complete-legacy`](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/master/examples/complete-legacy).

```hcl
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 2.0"

  bucket = "my-awesome-bucket"
  acl    = "log-delivery-write"
}

terraform {
  required_providers {
    aws = "~> 3.69.0" # or anything lower than 3.75.0
  }
}
```

### After 3.x Example

See code in [`examples/complete`](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/master/examples/complete).

```hcl
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket = "my-awesome-bucket"
  acl    = "log-delivery-write"
}

terraform {
  required_providers {
    aws = ">= 4.5" # or anything higher than 4.5.0
  }
}
```

After the code is updated, you need run `terraform init -upgrade` to download newer AWS provider, and then import S3 bucket ACL using such command:

```
terraform import "module.s3_bucket.aws_s3_bucket_acl.this[0]" my-awesome-bucket,log-delivery-write
```

Where `log-delivery-write` is the value of `acl` argument in the module block above.

Read more about [import in the official documentation for `aws_s3_bucket_acl`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl#import).

#### Import existing resources (required during the migration from v2.x of this module)

During the migration to v3.x of this module, several S3 resources will be created by this module. In order to guarantee the best experience and prevent data loss, you will need to import them into terraform state using commands like these:

```bash
terraform import "module.s3_bucket.aws_s3_bucket_acl.this[0]" <bucket-name>,<acl>
terraform import "module.s3_bucket.aws_s3_bucket_logging.this[0]" <bucket-name>
terraform import "module.s3_bucket.aws_s3_bucket_website_configuration.this[0]" <bucket-name>,<account-id>
terraform import "module.s3_bucket.aws_s3_bucket_versioning.this[0]" <bucket-name>,<account-id>
terraform import "module.s3_bucket.aws_s3_bucket_server_side_encryption_configuration.this[0]" <bucket-name>,<account-id>
terraform import "module.s3_bucket.aws_s3_bucket_request_payment_configuration.this[0]" <bucket-name>,<account-id>
terraform import "module.s3_bucket.aws_s3_bucket_accelerate_configuration.this[0]" <bucket-name>,<account-id>
terraform import "module.s3_bucket.aws_s3_bucket_policy.this[0]" <bucket-name>
terraform import "module.s3_bucket.aws_s3_bucket_ownership_controls.this[0]" <bucket-name>
terraform import "module.s3_bucket.aws_s3_bucket_cors_configuration.this[0]" <bucket-name>,<account-id>
terraform import "module.s3_bucket.aws_s3_bucket_object_lock_configuration.this[0]" <bucket-name>,<account-id>
terraform import "module.s3_bucket.aws_s3_bucket_public_access_block.this[0]" <bucket-name>
terraform import "module.s3_bucket.aws_s3_bucket_lifecycle_configuration.this[0]" <bucket-name>,<account-id>
terraform import "module.s3_bucket.aws_s3_bucket_replication_configuration.this[0]" <bucket-name>
```

Where `s3_bucket` is the name of your module definition, `bucket-name` is the name of the bucket, `acl` is the bucket ACL (e.g. `private`, `log-delivery-write`, etc), `<account-id>` is your AWS account number (required only if `expected_bucket_owner` is set in the code).
