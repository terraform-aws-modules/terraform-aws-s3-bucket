[0m[1mdata.aws_availability_zones.available: Reading...[0m[0m
[0m[1mdata.aws_caller_identity.this: Reading...[0m[0m
[0m[1mmodule.s3_bucket.data.aws_caller_identity.current: Reading...[0m[0m
[0m[1mmodule.s3_bucket.data.aws_partition.current: Reading...[0m[0m
[0m[1mdata.aws_iam_policy_document.s3_files_assume_role: Reading...[0m[0m
[0m[1mmodule.s3_bucket.data.aws_region.current: Reading...[0m[0m
[0m[1mmodule.s3_bucket.data.aws_partition.current: Read complete after 0s [id=aws][0m
[0m[1mmodule.s3_bucket.data.aws_region.current: Read complete after 0s [id=eu-west-1][0m
[0m[1mdata.aws_iam_policy_document.s3_files_assume_role: Read complete after 0s [id=406086218][0m
[0m[1mdata.aws_availability_zones.available: Read complete after 1s [id=eu-west-1][0m
[0m[1mdata.aws_caller_identity.this: Read complete after 1s [id=600627358256][0m
[0m[1mmodule.s3_bucket.data.aws_caller_identity.current: Read complete after 1s [id=600627358256][0m

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  [32m+[0m create[0m
 [36m<=[0m read (data resources)[0m

Terraform will perform the following actions:

[1m  # data.aws_iam_policy_document.s3_files_bucket_access[0m will be read during apply
  # (config refers to values not yet known)
[0m [36m<=[0m[0m data "aws_iam_policy_document" "s3_files_bucket_access" {
      [32m+[0m[0m id            = (known after apply)
      [32m+[0m[0m json          = (known after apply)
      [32m+[0m[0m minified_json = (known after apply)

      [32m+[0m[0m statement {
          [32m+[0m[0m actions   = [
              [32m+[0m[0m "s3:GetBucketLocation",
              [32m+[0m[0m "s3:ListBucket",
              [32m+[0m[0m "s3:ListBucketMultipartUploads",
            ]
          [32m+[0m[0m effect    = "Allow"
          [32m+[0m[0m resources = [
              [32m+[0m[0m (known after apply),
            ]
          [32m+[0m[0m sid       = "AllowBucketListing"
        }
      [32m+[0m[0m statement {
          [32m+[0m[0m actions   = [
              [32m+[0m[0m "s3:AbortMultipartUpload",
              [32m+[0m[0m "s3:DeleteObject",
              [32m+[0m[0m "s3:GetObject",
              [32m+[0m[0m "s3:ListMultipartUploadParts",
              [32m+[0m[0m "s3:PutObject",
            ]
          [32m+[0m[0m effect    = "Allow"
          [32m+[0m[0m resources = [
              [32m+[0m[0m (known after apply),
            ]
          [32m+[0m[0m sid       = "AllowObjectReadWrite"
        }
    }

[1m  # aws_iam_role.s3_files[0m will be created
[0m  [32m+[0m[0m resource "aws_iam_role" "s3_files" {
      [32m+[0m[0m arn                   = (known after apply)
      [32m+[0m[0m assume_role_policy    = jsonencode(
            {
              [32m+[0m[0m Statement = [
                  [32m+[0m[0m {
                      [32m+[0m[0m Action    = "sts:AssumeRole"
                      [32m+[0m[0m Effect    = "Allow"
                      [32m+[0m[0m Principal = {
                          [32m+[0m[0m Service = "elasticfilesystem.amazonaws.com"
                        }
                    },
                ]
              [32m+[0m[0m Version   = "2012-10-17"
            }
        )
      [32m+[0m[0m create_date           = (known after apply)
      [32m+[0m[0m force_detach_policies = false
      [32m+[0m[0m id                    = (known after apply)
      [32m+[0m[0m managed_policy_arns   = (known after apply)
      [32m+[0m[0m max_session_duration  = 3600
      [32m+[0m[0m name                  = (known after apply)
      [32m+[0m[0m name_prefix           = "s3-files-example-"
      [32m+[0m[0m path                  = "/"
      [32m+[0m[0m tags                  = {
          [32m+[0m[0m "AccountId" = "600627358256"
          [32m+[0m[0m "Example"   = "s3-files"
        }
      [32m+[0m[0m tags_all              = {
          [32m+[0m[0m "AccountId" = "600627358256"
          [32m+[0m[0m "Example"   = "s3-files"
        }
      [32m+[0m[0m unique_id             = (known after apply)
    }

[1m  # aws_iam_role_policy.s3_files_bucket_access[0m will be created
[0m  [32m+[0m[0m resource "aws_iam_role_policy" "s3_files_bucket_access" {
      [32m+[0m[0m id          = (known after apply)
      [32m+[0m[0m name        = "s3-files-bucket-access"
      [32m+[0m[0m name_prefix = (known after apply)
      [32m+[0m[0m policy      = (known after apply)
      [32m+[0m[0m role        = (known after apply)
    }

[1m  # aws_security_group.s3_files[0m will be created
[0m  [32m+[0m[0m resource "aws_security_group" "s3_files" {
      [32m+[0m[0m arn                    = (known after apply)
      [32m+[0m[0m description            = "Security group for S3 Files mount targets"
      [32m+[0m[0m egress                 = [
          [32m+[0m[0m {
              [32m+[0m[0m cidr_blocks      = [
                  [32m+[0m[0m "0.0.0.0/0",
                ]
              [32m+[0m[0m description      = ""
              [32m+[0m[0m from_port        = 0
              [32m+[0m[0m ipv6_cidr_blocks = [
                  [32m+[0m[0m "::/0",
                ]
              [32m+[0m[0m prefix_list_ids  = []
              [32m+[0m[0m protocol         = "-1"
              [32m+[0m[0m security_groups  = []
              [32m+[0m[0m self             = false
              [32m+[0m[0m to_port          = 0
            },
        ]
      [32m+[0m[0m id                     = (known after apply)
      [32m+[0m[0m ingress                = [
          [32m+[0m[0m {
              [32m+[0m[0m cidr_blocks      = [
                  [32m+[0m[0m "10.42.0.0/16",
                ]
              [32m+[0m[0m description      = ""
              [32m+[0m[0m from_port        = 2049
              [32m+[0m[0m ipv6_cidr_blocks = []
              [32m+[0m[0m prefix_list_ids  = []
              [32m+[0m[0m protocol         = "tcp"
              [32m+[0m[0m security_groups  = []
              [32m+[0m[0m self             = false
              [32m+[0m[0m to_port          = 2049
            },
        ]
      [32m+[0m[0m name                   = (known after apply)
      [32m+[0m[0m name_prefix            = "s3-files-example-"
      [32m+[0m[0m owner_id               = (known after apply)
      [32m+[0m[0m region                 = "eu-west-1"
      [32m+[0m[0m revoke_rules_on_delete = false
      [32m+[0m[0m tags                   = {
          [32m+[0m[0m "AccountId" = "600627358256"
          [32m+[0m[0m "Example"   = "s3-files"
          [32m+[0m[0m "Name"      = "s3-files-example-sg"
        }
      [32m+[0m[0m tags_all               = {
          [32m+[0m[0m "AccountId" = "600627358256"
          [32m+[0m[0m "Example"   = "s3-files"
          [32m+[0m[0m "Name"      = "s3-files-example-sg"
        }
      [32m+[0m[0m vpc_id                 = (known after apply)
    }

[1m  # aws_subnet.private_a[0m will be created
[0m  [32m+[0m[0m resource "aws_subnet" "private_a" {
      [32m+[0m[0m arn                                            = (known after apply)
      [32m+[0m[0m assign_ipv6_address_on_creation                = false
      [32m+[0m[0m availability_zone                              = "eu-west-1a"
      [32m+[0m[0m availability_zone_id                           = (known after apply)
      [32m+[0m[0m cidr_block                                     = "10.42.1.0/24"
      [32m+[0m[0m enable_dns64                                   = false
      [32m+[0m[0m enable_resource_name_dns_a_record_on_launch    = false
      [32m+[0m[0m enable_resource_name_dns_aaaa_record_on_launch = false
      [32m+[0m[0m id                                             = (known after apply)
      [32m+[0m[0m ipv6_cidr_block                                = (known after apply)
      [32m+[0m[0m ipv6_cidr_block_association_id                 = (known after apply)
      [32m+[0m[0m ipv6_native                                    = false
      [32m+[0m[0m map_public_ip_on_launch                        = false
      [32m+[0m[0m owner_id                                       = (known after apply)
      [32m+[0m[0m private_dns_hostname_type_on_launch            = (known after apply)
      [32m+[0m[0m region                                         = "eu-west-1"
      [32m+[0m[0m tags                                           = {
          [32m+[0m[0m "AccountId" = "600627358256"
          [32m+[0m[0m "Example"   = "s3-files"
          [32m+[0m[0m "Name"      = "s3-files-example-private-a"
        }
      [32m+[0m[0m tags_all                                       = {
          [32m+[0m[0m "AccountId" = "600627358256"
          [32m+[0m[0m "Example"   = "s3-files"
          [32m+[0m[0m "Name"      = "s3-files-example-private-a"
        }
      [32m+[0m[0m vpc_id                                         = (known after apply)
    }

[1m  # aws_subnet.private_b[0m will be created
[0m  [32m+[0m[0m resource "aws_subnet" "private_b" {
      [32m+[0m[0m arn                                            = (known after apply)
      [32m+[0m[0m assign_ipv6_address_on_creation                = false
      [32m+[0m[0m availability_zone                              = "eu-west-1b"
      [32m+[0m[0m availability_zone_id                           = (known after apply)
      [32m+[0m[0m cidr_block                                     = "10.42.2.0/24"
      [32m+[0m[0m enable_dns64                                   = false
      [32m+[0m[0m enable_resource_name_dns_a_record_on_launch    = false
      [32m+[0m[0m enable_resource_name_dns_aaaa_record_on_launch = false
      [32m+[0m[0m id                                             = (known after apply)
      [32m+[0m[0m ipv6_cidr_block                                = (known after apply)
      [32m+[0m[0m ipv6_cidr_block_association_id                 = (known after apply)
      [32m+[0m[0m ipv6_native                                    = false
      [32m+[0m[0m map_public_ip_on_launch                        = false
      [32m+[0m[0m owner_id                                       = (known after apply)
      [32m+[0m[0m private_dns_hostname_type_on_launch            = (known after apply)
      [32m+[0m[0m region                                         = "eu-west-1"
      [32m+[0m[0m tags                                           = {
          [32m+[0m[0m "AccountId" = "600627358256"
          [32m+[0m[0m "Example"   = "s3-files"
          [32m+[0m[0m "Name"      = "s3-files-example-private-b"
        }
      [32m+[0m[0m tags_all                                       = {
          [32m+[0m[0m "AccountId" = "600627358256"
          [32m+[0m[0m "Example"   = "s3-files"
          [32m+[0m[0m "Name"      = "s3-files-example-private-b"
        }
      [32m+[0m[0m vpc_id                                         = (known after apply)
    }

[1m  # aws_vpc.this[0m will be created
[0m  [32m+[0m[0m resource "aws_vpc" "this" {
      [32m+[0m[0m arn                                  = (known after apply)
      [32m+[0m[0m cidr_block                           = "10.42.0.0/16"
      [32m+[0m[0m default_network_acl_id               = (known after apply)
      [32m+[0m[0m default_route_table_id               = (known after apply)
      [32m+[0m[0m default_security_group_id            = (known after apply)
      [32m+[0m[0m dhcp_options_id                      = (known after apply)
      [32m+[0m[0m enable_dns_hostnames                 = true
      [32m+[0m[0m enable_dns_support                   = true
      [32m+[0m[0m enable_network_address_usage_metrics = (known after apply)
      [32m+[0m[0m id                                   = (known after apply)
      [32m+[0m[0m instance_tenancy                     = "default"
      [32m+[0m[0m ipv6_association_id                  = (known after apply)
      [32m+[0m[0m ipv6_cidr_block                      = (known after apply)
      [32m+[0m[0m ipv6_cidr_block_network_border_group = (known after apply)
      [32m+[0m[0m main_route_table_id                  = (known after apply)
      [32m+[0m[0m owner_id                             = (known after apply)
      [32m+[0m[0m region                               = "eu-west-1"
      [32m+[0m[0m tags                                 = {
          [32m+[0m[0m "AccountId" = "600627358256"
          [32m+[0m[0m "Example"   = "s3-files"
          [32m+[0m[0m "Name"      = "s3-files-example-vpc"
        }
      [32m+[0m[0m tags_all                             = {
          [32m+[0m[0m "AccountId" = "600627358256"
          [32m+[0m[0m "Example"   = "s3-files"
          [32m+[0m[0m "Name"      = "s3-files-example-vpc"
        }
    }

[1m  # random_pet.this[0m will be created
[0m  [32m+[0m[0m resource "random_pet" "this" {
      [32m+[0m[0m id        = (known after apply)
      [32m+[0m[0m length    = 2
      [32m+[0m[0m separator = "-"
    }

[1m  # module.s3_bucket.aws_s3_bucket.this[0][0m will be created
[0m  [32m+[0m[0m resource "aws_s3_bucket" "this" {
      [32m+[0m[0m acceleration_status         = (known after apply)
      [32m+[0m[0m acl                         = (known after apply)
      [32m+[0m[0m arn                         = (known after apply)
      [32m+[0m[0m bucket                      = (known after apply)
      [32m+[0m[0m bucket_domain_name          = (known after apply)
      [32m+[0m[0m bucket_namespace            = (known after apply)
      [32m+[0m[0m bucket_prefix               = (known after apply)
      [32m+[0m[0m bucket_region               = (known after apply)
      [32m+[0m[0m bucket_regional_domain_name = (known after apply)
      [32m+[0m[0m force_destroy               = true
      [32m+[0m[0m hosted_zone_id              = (known after apply)
      [32m+[0m[0m id                          = (known after apply)
      [32m+[0m[0m object_lock_enabled         = false
      [32m+[0m[0m policy                      = (known after apply)
      [32m+[0m[0m region                      = "eu-west-1"
      [32m+[0m[0m request_payer               = (known after apply)
      [32m+[0m[0m tags                        = {
          [32m+[0m[0m "AccountId" = "600627358256"
          [32m+[0m[0m "Example"   = "s3-files"
        }
      [32m+[0m[0m tags_all                    = {
          [32m+[0m[0m "AccountId" = "600627358256"
          [32m+[0m[0m "Example"   = "s3-files"
        }
      [32m+[0m[0m website_domain              = (known after apply)
      [32m+[0m[0m website_endpoint            = (known after apply)
    }

[1m  # module.s3_bucket.aws_s3_bucket_public_access_block.this[0][0m will be created
[0m  [32m+[0m[0m resource "aws_s3_bucket_public_access_block" "this" {
      [32m+[0m[0m block_public_acls       = true
      [32m+[0m[0m block_public_policy     = true
      [32m+[0m[0m bucket                  = (known after apply)
      [32m+[0m[0m id                      = (known after apply)
      [32m+[0m[0m ignore_public_acls      = true
      [32m+[0m[0m region                  = "eu-west-1"
      [32m+[0m[0m restrict_public_buckets = true
      [32m+[0m[0m skip_destroy            = true
    }

[1m  # module.s3_bucket.aws_s3_bucket_versioning.this[0][0m will be created
[0m  [32m+[0m[0m resource "aws_s3_bucket_versioning" "this" {
      [32m+[0m[0m bucket = (known after apply)
      [32m+[0m[0m id     = (known after apply)
      [32m+[0m[0m region = "eu-west-1"

      [32m+[0m[0m versioning_configuration {
          [32m+[0m[0m mfa_delete = (known after apply)
          [32m+[0m[0m status     = "Enabled"
        }
    }

[1m  # module.s3_files.data.aws_caller_identity.this[0][0m will be read during apply
  # (depends on a resource or a module with changes pending)
[0m [36m<=[0m[0m data "aws_caller_identity" "this" {
      [32m+[0m[0m account_id = (known after apply)
      [32m+[0m[0m arn        = (known after apply)
      [32m+[0m[0m id         = (known after apply)
      [32m+[0m[0m user_id    = (known after apply)
    }

[1m  # module.s3_files.data.aws_iam_policy_document.this[0][0m will be read during apply
  # (config refers to values not yet known)
[0m [36m<=[0m[0m data "aws_iam_policy_document" "this" {
      [32m+[0m[0m id            = (known after apply)
      [32m+[0m[0m json          = (known after apply)
      [32m+[0m[0m minified_json = (known after apply)

      [32m+[0m[0m statement {
          [32m+[0m[0m actions   = [
              [32m+[0m[0m "s3files:ClientMount",
            ]
          [32m+[0m[0m effect    = "Allow"
          [32m+[0m[0m resources = [
              [32m+[0m[0m "*",
            ]
          [32m+[0m[0m sid       = "AllowAccountRootClientMount"

          [32m+[0m[0m principals {
              [32m+[0m[0m identifiers = [
                  [32m+[0m[0m (known after apply),
                ]
              [32m+[0m[0m type        = "AWS"
            }
        }
    }

[1m  # module.s3_files.data.aws_partition.this[0][0m will be read during apply
  # (depends on a resource or a module with changes pending)
[0m [36m<=[0m[0m data "aws_partition" "this" {
      [32m+[0m[0m dns_suffix         = (known after apply)
      [32m+[0m[0m id                 = (known after apply)
      [32m+[0m[0m partition          = (known after apply)
      [32m+[0m[0m reverse_dns_prefix = (known after apply)
    }

[1m  # module.s3_files.data.aws_security_group.this[0][0m will be read during apply
  # (config refers to values not yet known)
[0m [36m<=[0m[0m data "aws_security_group" "this" {
      [32m+[0m[0m arn         = (known after apply)
      [32m+[0m[0m description = (known after apply)
      [32m+[0m[0m id          = (known after apply)
      [32m+[0m[0m name        = (known after apply)
      [32m+[0m[0m region      = (known after apply)
      [32m+[0m[0m tags        = (known after apply)
      [32m+[0m[0m vpc_id      = (known after apply)
    }

[1m  # module.s3_files.data.aws_subnet.this[0][0m will be read during apply
  # (config refers to values not yet known)
[0m [36m<=[0m[0m data "aws_subnet" "this" {
      [32m+[0m[0m arn                                            = (known after apply)
      [32m+[0m[0m assign_ipv6_address_on_creation                = (known after apply)
      [32m+[0m[0m availability_zone                              = (known after apply)
      [32m+[0m[0m availability_zone_id                           = (known after apply)
      [32m+[0m[0m available_ip_address_count                     = (known after apply)
      [32m+[0m[0m cidr_block                                     = (known after apply)
      [32m+[0m[0m customer_owned_ipv4_pool                       = (known after apply)
      [32m+[0m[0m default_for_az                                 = (known after apply)
      [32m+[0m[0m enable_dns64                                   = (known after apply)
      [32m+[0m[0m enable_lni_at_device_index                     = (known after apply)
      [32m+[0m[0m enable_resource_name_dns_a_record_on_launch    = (known after apply)
      [32m+[0m[0m enable_resource_name_dns_aaaa_record_on_launch = (known after apply)
      [32m+[0m[0m id                                             = (known after apply)
      [32m+[0m[0m ipv6_cidr_block                                = (known after apply)
      [32m+[0m[0m ipv6_cidr_block_association_id                 = (known after apply)
      [32m+[0m[0m ipv6_native                                    = (known after apply)
      [32m+[0m[0m map_customer_owned_ip_on_launch                = (known after apply)
      [32m+[0m[0m map_public_ip_on_launch                        = (known after apply)
      [32m+[0m[0m outpost_arn                                    = (known after apply)
      [32m+[0m[0m owner_id                                       = (known after apply)
      [32m+[0m[0m private_dns_hostname_type_on_launch            = (known after apply)
      [32m+[0m[0m region                                         = (known after apply)
      [32m+[0m[0m state                                          = (known after apply)
      [32m+[0m[0m tags                                           = (known after apply)
      [32m+[0m[0m vpc_id                                         = (known after apply)
    }

[1m  # module.s3_files.data.aws_subnet.this[1][0m will be read during apply
  # (config refers to values not yet known)
[0m [36m<=[0m[0m data "aws_subnet" "this" {
      [32m+[0m[0m arn                                            = (known after apply)
      [32m+[0m[0m assign_ipv6_address_on_creation                = (known after apply)
      [32m+[0m[0m availability_zone                              = (known after apply)
      [32m+[0m[0m availability_zone_id                           = (known after apply)
      [32m+[0m[0m available_ip_address_count                     = (known after apply)
      [32m+[0m[0m cidr_block                                     = (known after apply)
      [32m+[0m[0m customer_owned_ipv4_pool                       = (known after apply)
      [32m+[0m[0m default_for_az                                 = (known after apply)
      [32m+[0m[0m enable_dns64                                   = (known after apply)
      [32m+[0m[0m enable_lni_at_device_index                     = (known after apply)
      [32m+[0m[0m enable_resource_name_dns_a_record_on_launch    = (known after apply)
      [32m+[0m[0m enable_resource_name_dns_aaaa_record_on_launch = (known after apply)
      [32m+[0m[0m id                                             = (known after apply)
      [32m+[0m[0m ipv6_cidr_block                                = (known after apply)
      [32m+[0m[0m ipv6_cidr_block_association_id                 = (known after apply)
      [32m+[0m[0m ipv6_native                                    = (known after apply)
      [32m+[0m[0m map_customer_owned_ip_on_launch                = (known after apply)
      [32m+[0m[0m map_public_ip_on_launch                        = (known after apply)
      [32m+[0m[0m outpost_arn                                    = (known after apply)
      [32m+[0m[0m owner_id                                       = (known after apply)
      [32m+[0m[0m private_dns_hostname_type_on_launch            = (known after apply)
      [32m+[0m[0m region                                         = (known after apply)
      [32m+[0m[0m state                                          = (known after apply)
      [32m+[0m[0m tags                                           = (known after apply)
      [32m+[0m[0m vpc_id                                         = (known after apply)
    }

[1m  # module.s3_files.aws_s3files_access_point.this["test-app-ap"][0m will be created
[0m  [32m+[0m[0m resource "aws_s3files_access_point" "this" {
      [32m+[0m[0m arn            = (known after apply)
      [32m+[0m[0m file_system_id = (known after apply)
      [32m+[0m[0m id             = (known after apply)
      [32m+[0m[0m name           = (known after apply)
      [32m+[0m[0m owner_id       = (known after apply)
      [32m+[0m[0m region         = "eu-west-1"
      [32m+[0m[0m status         = (known after apply)
      [32m+[0m[0m tags           = {
          [32m+[0m[0m "AccountId" = "600627358256"
          [32m+[0m[0m "Example"   = "s3-files"
        }
      [32m+[0m[0m tags_all       = {
          [32m+[0m[0m "AccountId" = "600627358256"
          [32m+[0m[0m "Example"   = "s3-files"
        }

      [32m+[0m[0m posix_user {
          [32m+[0m[0m gid = 1000
          [32m+[0m[0m uid = 1000
        }

      [32m+[0m[0m root_directory {
          [32m+[0m[0m path = "/test-app-data"

          [32m+[0m[0m creation_permissions {
              [32m+[0m[0m owner_gid   = 1000
              [32m+[0m[0m owner_uid   = 1000
              [32m+[0m[0m permissions = "0755"
            }
        }
    }

[1m  # module.s3_files.aws_s3files_file_system.this[0][0m will be created
[0m  [32m+[0m[0m resource "aws_s3files_file_system" "this" {
      [32m+[0m[0m arn            = (known after apply)
      [32m+[0m[0m bucket         = (known after apply)
      [32m+[0m[0m creation_time  = (known after apply)
      [32m+[0m[0m id             = (known after apply)
      [32m+[0m[0m kms_key_id     = (known after apply)
      [32m+[0m[0m name           = (known after apply)
      [32m+[0m[0m owner_id       = (known after apply)
      [32m+[0m[0m region         = "eu-west-1"
      [32m+[0m[0m role_arn       = (known after apply)
      [32m+[0m[0m status         = (known after apply)
      [32m+[0m[0m status_message = (known after apply)
      [32m+[0m[0m tags           = {
          [32m+[0m[0m "AccountId" = "600627358256"
          [32m+[0m[0m "Example"   = "s3-files"
        }
      [32m+[0m[0m tags_all       = {
          [32m+[0m[0m "AccountId" = "600627358256"
          [32m+[0m[0m "Example"   = "s3-files"
        }
    }

[1m  # module.s3_files.aws_s3files_file_system_policy.this[0][0m will be created
[0m  [32m+[0m[0m resource "aws_s3files_file_system_policy" "this" {
      [32m+[0m[0m file_system_id = (known after apply)
      [32m+[0m[0m policy         = (known after apply)
      [32m+[0m[0m region         = "eu-west-1"
    }

[1m  # module.s3_files.aws_s3files_mount_target.this[0][0m will be created
[0m  [32m+[0m[0m resource "aws_s3files_mount_target" "this" {
      [32m+[0m[0m availability_zone_id = (known after apply)
      [32m+[0m[0m file_system_id       = (known after apply)
      [32m+[0m[0m id                   = (known after apply)
      [32m+[0m[0m ipv4_address         = (known after apply)
      [32m+[0m[0m ipv6_address         = (known after apply)
      [32m+[0m[0m network_interface_id = (known after apply)
      [32m+[0m[0m owner_id             = (known after apply)
      [32m+[0m[0m region               = "eu-west-1"
      [32m+[0m[0m security_groups      = [
          [32m+[0m[0m (known after apply),
        ]
      [32m+[0m[0m status               = (known after apply)
      [32m+[0m[0m status_message       = (known after apply)
      [32m+[0m[0m subnet_id            = (known after apply)
      [32m+[0m[0m vpc_id               = (known after apply)
    }

[1m  # module.s3_files.aws_s3files_mount_target.this[1][0m will be created
[0m  [32m+[0m[0m resource "aws_s3files_mount_target" "this" {
      [32m+[0m[0m availability_zone_id = (known after apply)
      [32m+[0m[0m file_system_id       = (known after apply)
      [32m+[0m[0m id                   = (known after apply)
      [32m+[0m[0m ipv4_address         = (known after apply)
      [32m+[0m[0m ipv6_address         = (known after apply)
      [32m+[0m[0m network_interface_id = (known after apply)
      [32m+[0m[0m owner_id             = (known after apply)
      [32m+[0m[0m region               = "eu-west-1"
      [32m+[0m[0m security_groups      = [
          [32m+[0m[0m (known after apply),
        ]
      [32m+[0m[0m status               = (known after apply)
      [32m+[0m[0m status_message       = (known after apply)
      [32m+[0m[0m subnet_id            = (known after apply)
      [32m+[0m[0m vpc_id               = (known after apply)
    }

[1mPlan:[0m 15 to add, 0 to change, 0 to destroy.
[0m
Changes to Outputs:
  [32m+[0m[0m s3_bucket_arn                               = (known after apply)
  [32m+[0m[0m s3_bucket_id                                = (known after apply)
  [32m+[0m[0m s3_bucket_versioning_status                 = "Enabled"
  [32m+[0m[0m s3_files_access_points                      = {
      [32m+[0m[0m test-app-ap = {
          [32m+[0m[0m arn  = (known after apply)
          [32m+[0m[0m id   = (known after apply)
          [32m+[0m[0m name = (known after apply)
        }
    }
  [32m+[0m[0m s3_files_file_system_arn                    = (known after apply)
  [32m+[0m[0m s3_files_file_system_id                     = (known after apply)
  [32m+[0m[0m s3_files_mount_target_network_interface_ids = [
      [32m+[0m[0m (known after apply),
      [32m+[0m[0m (known after apply),
    ]
[0m[1mrandom_pet.this: Creating...[0m[0m
[0m[1mrandom_pet.this: Creation complete after 0s [id=credible-mole][0m
[0m[1maws_vpc.this: Creating...[0m[0m
[0m[1maws_iam_role.s3_files: Creating...[0m[0m
[0m[1mmodule.s3_bucket.aws_s3_bucket.this[0]: Creating...[0m[0m
[0m[1maws_iam_role.s3_files: Creation complete after 2s [id=s3-files-example-20260514183042483500000001][0m
[0m[1maws_vpc.this: Creation complete after 5s [id=vpc-089cf1695a7561159][0m
[0m[1maws_subnet.private_a: Creating...[0m[0m
[0m[1maws_subnet.private_b: Creating...[0m[0m
[0m[1maws_security_group.s3_files: Creating...[0m[0m
[0m[1maws_subnet.private_a: Creation complete after 1s [id=subnet-0d590e7466f0a9d11][0m
[0m[1maws_subnet.private_b: Creation complete after 1s [id=subnet-004552d2afad1225c][0m
[0m[1mmodule.s3_bucket.aws_s3_bucket.this[0]: Creation complete after 6s [id=s3-files-credible-mole][0m
[0m[1mdata.aws_iam_policy_document.s3_files_bucket_access: Reading...[0m[0m
[0m[1mmodule.s3_bucket.aws_s3_bucket_public_access_block.this[0]: Creating...[0m[0m
[0m[1mmodule.s3_bucket.aws_s3_bucket_versioning.this[0]: Creating...[0m[0m
[0m[1mdata.aws_iam_policy_document.s3_files_bucket_access: Read complete after 0s [id=2399904734][0m
[0m[1maws_iam_role_policy.s3_files_bucket_access: Creating...[0m[0m
[0m[1maws_iam_role_policy.s3_files_bucket_access: Creation complete after 1s [id=s3-files-example-20260514183042483500000001:s3-files-bucket-access][0m
[0m[1mmodule.s3_bucket.aws_s3_bucket_public_access_block.this[0]: Creation complete after 2s [id=s3-files-credible-mole][0m
[0m[1mmodule.s3_bucket.aws_s3_bucket_versioning.this[0]: Creation complete after 3s [id=s3-files-credible-mole][0m
[0m[1mmodule.s3_files.data.aws_caller_identity.this[0]: Reading...[0m[0m
[0m[1mmodule.s3_files.data.aws_subnet.this[1]: Reading...[0m[0m
[0m[1mmodule.s3_files.data.aws_subnet.this[0]: Reading...[0m[0m
[0m[1mmodule.s3_files.data.aws_partition.this[0]: Reading...[0m[0m
[0m[1mmodule.s3_files.data.aws_partition.this[0]: Read complete after 0s [id=aws][0m
[0m[1mmodule.s3_files.data.aws_subnet.this[1]: Read complete after 0s [id=subnet-004552d2afad1225c][0m
[0m[1mmodule.s3_files.data.aws_subnet.this[0]: Read complete after 0s [id=subnet-0d590e7466f0a9d11][0m
[0m[1maws_security_group.s3_files: Creation complete after 5s [id=sg-078cf7303608c178b][0m
[0m[1mmodule.s3_files.data.aws_security_group.this[0]: Reading...[0m[0m
[0m[1mmodule.s3_files.data.aws_security_group.this[0]: Read complete after 0s [id=sg-078cf7303608c178b][0m
[0m[1mmodule.s3_files.aws_s3files_file_system.this[0]: Creating...[0m[0m
[0m[1mmodule.s3_files.data.aws_caller_identity.this[0]: Read complete after 1s [id=600627358256][0m
[0m[1mmodule.s3_files.data.aws_iam_policy_document.this[0]: Reading...[0m[0m
[0m[1mmodule.s3_files.data.aws_iam_policy_document.this[0]: Read complete after 0s [id=1457466757][0m
[0m[1mmodule.s3_files.aws_s3files_file_system.this[0]: Still creating... [10s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_file_system.this[0]: Still creating... [20s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_file_system.this[0]: Creation complete after 22s [id=fs-0edb587486947d4f6][0m
[0m[1mmodule.s3_files.aws_s3files_file_system_policy.this[0]: Creating...[0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[0]: Creating...[0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[1]: Creating...[0m[0m
[0m[1mmodule.s3_files.aws_s3files_access_point.this["test-app-ap"]: Creating...[0m[0m
[0m[1mmodule.s3_files.aws_s3files_file_system_policy.this[0]: Creation complete after 0s[0m
[0m[1mmodule.s3_files.aws_s3files_access_point.this["test-app-ap"]: Creation complete after 1s [id=fsap-0fc85b46f1cdb99ab][0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[0]: Still creating... [10s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[1]: Still creating... [10s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[1]: Still creating... [20s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[0]: Still creating... [20s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[0]: Still creating... [30s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[1]: Still creating... [30s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[1]: Still creating... [40s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[0]: Still creating... [40s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[0]: Still creating... [50s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[1]: Still creating... [50s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[1]: Still creating... [1m0s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[0]: Still creating... [1m0s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[0]: Still creating... [1m10s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[1]: Still creating... [1m10s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[0]: Still creating... [1m20s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[1]: Still creating... [1m20s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[1]: Still creating... [1m30s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[0]: Still creating... [1m30s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[1]: Still creating... [1m40s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[0]: Still creating... [1m40s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[0]: Still creating... [1m50s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[1]: Still creating... [1m50s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[1]: Still creating... [2m0s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[0]: Still creating... [2m0s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[1]: Still creating... [2m10s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[0]: Still creating... [2m10s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[0]: Still creating... [2m20s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[1]: Still creating... [2m20s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[0]: Still creating... [2m30s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[1]: Still creating... [2m30s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[0]: Still creating... [2m40s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[1]: Still creating... [2m40s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[1]: Still creating... [2m50s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[0]: Still creating... [2m50s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[1]: Still creating... [3m0s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[0]: Still creating... [3m0s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[1]: Still creating... [3m10s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[0]: Still creating... [3m10s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[0]: Still creating... [3m20s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[1]: Still creating... [3m20s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[1]: Still creating... [3m30s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[0]: Still creating... [3m30s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[1]: Still creating... [3m40s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[0]: Still creating... [3m40s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[0]: Still creating... [3m50s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[1]: Still creating... [3m50s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[1]: Still creating... [4m0s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[0]: Still creating... [4m0s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[0]: Still creating... [4m10s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[1]: Still creating... [4m10s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[0]: Still creating... [4m20s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[1]: Still creating... [4m20s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[0]: Still creating... [4m30s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[1]: Still creating... [4m30s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[1]: Still creating... [4m40s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[0]: Still creating... [4m40s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[0]: Still creating... [4m50s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[1]: Still creating... [4m50s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[1]: Creation complete after 4m51s [id=fsmt-088c425c393a1c72e][0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[0]: Creation complete after 4m51s [id=fsmt-0bd2267a80e1ca1d2][0m
[0m[1m[32m
Apply complete! Resources: 15 added, 0 changed, 0 destroyed.
[0m[0m[1m[32m
Outputs:

[0ms3_bucket_arn = "arn:aws:s3:::s3-files-credible-mole"
s3_bucket_id = "s3-files-credible-mole"
s3_bucket_versioning_status = "Enabled"
s3_files_access_points = {
  "test-app-ap" = {
    "arn" = "arn:aws:s3files:eu-west-1:600627358256:file-system/fs-0edb587486947d4f6/access-point/fsap-0fc85b46f1cdb99ab"
    "id" = "fsap-0fc85b46f1cdb99ab"
    "name" = tostring(null)
  }
}
s3_files_file_system_arn = "arn:aws:s3files:eu-west-1:600627358256:file-system/fs-0edb587486947d4f6"
s3_files_file_system_id = "fs-0edb587486947d4f6"
s3_files_mount_target_network_interface_ids = [
  "eni-0221c8ccee35b2f72",
  "eni-0c2bb6541a33df240",
]
