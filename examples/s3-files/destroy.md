[0m[1mrandom_pet.this: Refreshing state... [id=credible-mole][0m
[0m[1mdata.aws_availability_zones.available: Reading...[0m[0m
[0m[1mmodule.s3_bucket.data.aws_partition.current: Reading...[0m[0m
[0m[1mmodule.s3_bucket.data.aws_caller_identity.current: Reading...[0m[0m
[0m[1mdata.aws_caller_identity.this: Reading...[0m[0m
[0m[1mmodule.s3_bucket.data.aws_region.current: Reading...[0m[0m
[0m[1mdata.aws_iam_policy_document.s3_files_assume_role: Reading...[0m[0m
[0m[1mmodule.s3_bucket.data.aws_region.current: Read complete after 0s [id=eu-west-1][0m
[0m[1mmodule.s3_bucket.data.aws_partition.current: Read complete after 0s [id=aws][0m
[0m[1mdata.aws_iam_policy_document.s3_files_assume_role: Read complete after 0s [id=406086218][0m
[0m[1mmodule.s3_bucket.data.aws_caller_identity.current: Read complete after 0s [id=600627358256][0m
[0m[1mdata.aws_caller_identity.this: Read complete after 0s [id=600627358256][0m
[0m[1maws_vpc.this: Refreshing state... [id=vpc-089cf1695a7561159][0m
[0m[1maws_iam_role.s3_files: Refreshing state... [id=s3-files-example-20260514183042483500000001][0m
[0m[1mmodule.s3_bucket.aws_s3_bucket.this[0]: Refreshing state... [id=s3-files-credible-mole][0m
[0m[1mdata.aws_availability_zones.available: Read complete after 1s [id=eu-west-1][0m
[0m[1maws_subnet.private_b: Refreshing state... [id=subnet-004552d2afad1225c][0m
[0m[1maws_subnet.private_a: Refreshing state... [id=subnet-0d590e7466f0a9d11][0m
[0m[1maws_security_group.s3_files: Refreshing state... [id=sg-078cf7303608c178b][0m
[0m[1mmodule.s3_bucket.aws_s3_bucket_public_access_block.this[0]: Refreshing state... [id=s3-files-credible-mole][0m
[0m[1mmodule.s3_bucket.aws_s3_bucket_versioning.this[0]: Refreshing state... [id=s3-files-credible-mole][0m
[0m[1mdata.aws_iam_policy_document.s3_files_bucket_access: Reading...[0m[0m
[0m[1mdata.aws_iam_policy_document.s3_files_bucket_access: Read complete after 0s [id=2399904734][0m
[0m[1maws_iam_role_policy.s3_files_bucket_access: Refreshing state... [id=s3-files-example-20260514183042483500000001:s3-files-bucket-access][0m
[0m[1mmodule.s3_files.data.aws_partition.this[0]: Reading...[0m[0m
[0m[1mmodule.s3_files.data.aws_caller_identity.this[0]: Reading...[0m[0m
[0m[1mmodule.s3_files.data.aws_security_group.this[0]: Reading...[0m[0m
[0m[1mmodule.s3_files.data.aws_subnet.this[1]: Reading...[0m[0m
[0m[1mmodule.s3_files.data.aws_subnet.this[0]: Reading...[0m[0m
[0m[1mmodule.s3_files.data.aws_partition.this[0]: Read complete after 0s [id=aws][0m
[0m[1mmodule.s3_files.data.aws_caller_identity.this[0]: Read complete after 0s [id=600627358256][0m
[0m[1mmodule.s3_files.data.aws_iam_policy_document.this[0]: Reading...[0m[0m
[0m[1mmodule.s3_files.data.aws_iam_policy_document.this[0]: Read complete after 0s [id=1457466757][0m
[0m[1mmodule.s3_files.data.aws_security_group.this[0]: Read complete after 0s [id=sg-078cf7303608c178b][0m
[0m[1mmodule.s3_files.data.aws_subnet.this[0]: Read complete after 0s [id=subnet-0d590e7466f0a9d11][0m
[0m[1mmodule.s3_files.data.aws_subnet.this[1]: Read complete after 1s [id=subnet-004552d2afad1225c][0m
[0m[1mmodule.s3_files.aws_s3files_file_system.this[0]: Refreshing state... [id=fs-0edb587486947d4f6][0m
[0m[1mmodule.s3_files.aws_s3files_file_system_policy.this[0]: Refreshing state...[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[1]: Refreshing state... [id=fsmt-088c425c393a1c72e][0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[0]: Refreshing state... [id=fsmt-0bd2267a80e1ca1d2][0m
[0m[1mmodule.s3_files.aws_s3files_access_point.this["test-app-ap"]: Refreshing state... [id=fsap-0fc85b46f1cdb99ab][0m

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  [31m-[0m destroy[0m

Terraform will perform the following actions:

[1m  # aws_iam_role.s3_files[0m will be [1m[31mdestroyed[0m
[0m  [31m-[0m[0m resource "aws_iam_role" "s3_files" {
      [31m-[0m[0m arn                   = "arn:aws:iam::600627358256:role/s3-files-example-20260514183042483500000001" [90m-> null[0m[0m
      [31m-[0m[0m assume_role_policy    = jsonencode(
            {
              [31m-[0m[0m Statement = [
                  [31m-[0m[0m {
                      [31m-[0m[0m Action    = "sts:AssumeRole"
                      [31m-[0m[0m Effect    = "Allow"
                      [31m-[0m[0m Principal = {
                          [31m-[0m[0m Service = "elasticfilesystem.amazonaws.com"
                        }
                    },
                ]
              [31m-[0m[0m Version   = "2012-10-17"
            }
        ) [90m-> null[0m[0m
      [31m-[0m[0m create_date           = "2026-05-14T18:30:42Z" [90m-> null[0m[0m
      [31m-[0m[0m force_detach_policies = false [90m-> null[0m[0m
      [31m-[0m[0m id                    = "s3-files-example-20260514183042483500000001" [90m-> null[0m[0m
      [31m-[0m[0m managed_policy_arns   = [] [90m-> null[0m[0m
      [31m-[0m[0m max_session_duration  = 3600 [90m-> null[0m[0m
      [31m-[0m[0m name                  = "s3-files-example-20260514183042483500000001" [90m-> null[0m[0m
      [31m-[0m[0m name_prefix           = "s3-files-example-" [90m-> null[0m[0m
      [31m-[0m[0m path                  = "/" [90m-> null[0m[0m
      [31m-[0m[0m tags                  = {
          [31m-[0m[0m "AccountId" = "600627358256"
          [31m-[0m[0m "Example"   = "s3-files"
        } [90m-> null[0m[0m
      [31m-[0m[0m tags_all              = {
          [31m-[0m[0m "AccountId" = "600627358256"
          [31m-[0m[0m "Example"   = "s3-files"
        } [90m-> null[0m[0m
      [31m-[0m[0m unique_id             = "AROAYXWBOFIYBTKFAWG7D" [90m-> null[0m[0m

      [31m-[0m[0m inline_policy {
          [31m-[0m[0m name   = "s3-files-bucket-access" [90m-> null[0m[0m
          [31m-[0m[0m policy = jsonencode(
                {
                  [31m-[0m[0m Statement = [
                      [31m-[0m[0m {
                          [31m-[0m[0m Action   = [
                              [31m-[0m[0m "s3:ListBucketMultipartUploads",
                              [31m-[0m[0m "s3:ListBucket",
                              [31m-[0m[0m "s3:GetBucketLocation",
                            ]
                          [31m-[0m[0m Effect   = "Allow"
                          [31m-[0m[0m Resource = "arn:aws:s3:::s3-files-credible-mole"
                          [31m-[0m[0m Sid      = "AllowBucketListing"
                        },
                      [31m-[0m[0m {
                          [31m-[0m[0m Action   = [
                              [31m-[0m[0m "s3:PutObject",
                              [31m-[0m[0m "s3:ListMultipartUploadParts",
                              [31m-[0m[0m "s3:GetObject",
                              [31m-[0m[0m "s3:DeleteObject",
                              [31m-[0m[0m "s3:AbortMultipartUpload",
                            ]
                          [31m-[0m[0m Effect   = "Allow"
                          [31m-[0m[0m Resource = "arn:aws:s3:::s3-files-credible-mole/*"
                          [31m-[0m[0m Sid      = "AllowObjectReadWrite"
                        },
                    ]
                  [31m-[0m[0m Version   = "2012-10-17"
                }
            ) [90m-> null[0m[0m
        }
    }

[1m  # aws_iam_role_policy.s3_files_bucket_access[0m will be [1m[31mdestroyed[0m
[0m  [31m-[0m[0m resource "aws_iam_role_policy" "s3_files_bucket_access" {
      [31m-[0m[0m id     = "s3-files-example-20260514183042483500000001:s3-files-bucket-access" [90m-> null[0m[0m
      [31m-[0m[0m name   = "s3-files-bucket-access" [90m-> null[0m[0m
      [31m-[0m[0m policy = jsonencode(
            {
              [31m-[0m[0m Statement = [
                  [31m-[0m[0m {
                      [31m-[0m[0m Action   = [
                          [31m-[0m[0m "s3:ListBucketMultipartUploads",
                          [31m-[0m[0m "s3:ListBucket",
                          [31m-[0m[0m "s3:GetBucketLocation",
                        ]
                      [31m-[0m[0m Effect   = "Allow"
                      [31m-[0m[0m Resource = "arn:aws:s3:::s3-files-credible-mole"
                      [31m-[0m[0m Sid      = "AllowBucketListing"
                    },
                  [31m-[0m[0m {
                      [31m-[0m[0m Action   = [
                          [31m-[0m[0m "s3:PutObject",
                          [31m-[0m[0m "s3:ListMultipartUploadParts",
                          [31m-[0m[0m "s3:GetObject",
                          [31m-[0m[0m "s3:DeleteObject",
                          [31m-[0m[0m "s3:AbortMultipartUpload",
                        ]
                      [31m-[0m[0m Effect   = "Allow"
                      [31m-[0m[0m Resource = "arn:aws:s3:::s3-files-credible-mole/*"
                      [31m-[0m[0m Sid      = "AllowObjectReadWrite"
                    },
                ]
              [31m-[0m[0m Version   = "2012-10-17"
            }
        ) [90m-> null[0m[0m
      [31m-[0m[0m role   = "s3-files-example-20260514183042483500000001" [90m-> null[0m[0m
    }

[1m  # aws_security_group.s3_files[0m will be [1m[31mdestroyed[0m
[0m  [31m-[0m[0m resource "aws_security_group" "s3_files" {
      [31m-[0m[0m arn                    = "arn:aws:ec2:eu-west-1:600627358256:security-group/sg-078cf7303608c178b" [90m-> null[0m[0m
      [31m-[0m[0m description            = "Security group for S3 Files mount targets" [90m-> null[0m[0m
      [31m-[0m[0m egress                 = [
          [31m-[0m[0m {
              [31m-[0m[0m cidr_blocks      = [
                  [31m-[0m[0m "0.0.0.0/0",
                ]
              [31m-[0m[0m description      = ""
              [31m-[0m[0m from_port        = 0
              [31m-[0m[0m ipv6_cidr_blocks = [
                  [31m-[0m[0m "::/0",
                ]
              [31m-[0m[0m prefix_list_ids  = []
              [31m-[0m[0m protocol         = "-1"
              [31m-[0m[0m security_groups  = []
              [31m-[0m[0m self             = false
              [31m-[0m[0m to_port          = 0
            },
        ] [90m-> null[0m[0m
      [31m-[0m[0m id                     = "sg-078cf7303608c178b" [90m-> null[0m[0m
      [31m-[0m[0m ingress                = [
          [31m-[0m[0m {
              [31m-[0m[0m cidr_blocks      = [
                  [31m-[0m[0m "10.42.0.0/16",
                ]
              [31m-[0m[0m description      = ""
              [31m-[0m[0m from_port        = 2049
              [31m-[0m[0m ipv6_cidr_blocks = []
              [31m-[0m[0m prefix_list_ids  = []
              [31m-[0m[0m protocol         = "tcp"
              [31m-[0m[0m security_groups  = []
              [31m-[0m[0m self             = false
              [31m-[0m[0m to_port          = 2049
            },
        ] [90m-> null[0m[0m
      [31m-[0m[0m name                   = "s3-files-example-20260514183046528100000002" [90m-> null[0m[0m
      [31m-[0m[0m name_prefix            = "s3-files-example-" [90m-> null[0m[0m
      [31m-[0m[0m owner_id               = "600627358256" [90m-> null[0m[0m
      [31m-[0m[0m region                 = "eu-west-1" [90m-> null[0m[0m
      [31m-[0m[0m revoke_rules_on_delete = false [90m-> null[0m[0m
      [31m-[0m[0m tags                   = {
          [31m-[0m[0m "AccountId" = "600627358256"
          [31m-[0m[0m "Example"   = "s3-files"
          [31m-[0m[0m "Name"      = "s3-files-example-sg"
        } [90m-> null[0m[0m
      [31m-[0m[0m tags_all               = {
          [31m-[0m[0m "AccountId" = "600627358256"
          [31m-[0m[0m "Example"   = "s3-files"
          [31m-[0m[0m "Name"      = "s3-files-example-sg"
        } [90m-> null[0m[0m
      [31m-[0m[0m vpc_id                 = "vpc-089cf1695a7561159" [90m-> null[0m[0m
    }

[1m  # aws_subnet.private_a[0m will be [1m[31mdestroyed[0m
[0m  [31m-[0m[0m resource "aws_subnet" "private_a" {
      [31m-[0m[0m arn                                            = "arn:aws:ec2:eu-west-1:600627358256:subnet/subnet-0d590e7466f0a9d11" [90m-> null[0m[0m
      [31m-[0m[0m assign_ipv6_address_on_creation                = false [90m-> null[0m[0m
      [31m-[0m[0m availability_zone                              = "eu-west-1a" [90m-> null[0m[0m
      [31m-[0m[0m availability_zone_id                           = "euw1-az2" [90m-> null[0m[0m
      [31m-[0m[0m cidr_block                                     = "10.42.1.0/24" [90m-> null[0m[0m
      [31m-[0m[0m enable_dns64                                   = false [90m-> null[0m[0m
      [31m-[0m[0m enable_lni_at_device_index                     = 0 [90m-> null[0m[0m
      [31m-[0m[0m enable_resource_name_dns_a_record_on_launch    = false [90m-> null[0m[0m
      [31m-[0m[0m enable_resource_name_dns_aaaa_record_on_launch = false [90m-> null[0m[0m
      [31m-[0m[0m id                                             = "subnet-0d590e7466f0a9d11" [90m-> null[0m[0m
      [31m-[0m[0m ipv6_native                                    = false [90m-> null[0m[0m
      [31m-[0m[0m map_customer_owned_ip_on_launch                = false [90m-> null[0m[0m
      [31m-[0m[0m map_public_ip_on_launch                        = false [90m-> null[0m[0m
      [31m-[0m[0m owner_id                                       = "600627358256" [90m-> null[0m[0m
      [31m-[0m[0m private_dns_hostname_type_on_launch            = "ip-name" [90m-> null[0m[0m
      [31m-[0m[0m region                                         = "eu-west-1" [90m-> null[0m[0m
      [31m-[0m[0m tags                                           = {
          [31m-[0m[0m "AccountId" = "600627358256"
          [31m-[0m[0m "Example"   = "s3-files"
          [31m-[0m[0m "Name"      = "s3-files-example-private-a"
        } [90m-> null[0m[0m
      [31m-[0m[0m tags_all                                       = {
          [31m-[0m[0m "AccountId" = "600627358256"
          [31m-[0m[0m "Example"   = "s3-files"
          [31m-[0m[0m "Name"      = "s3-files-example-private-a"
        } [90m-> null[0m[0m
      [31m-[0m[0m vpc_id                                         = "vpc-089cf1695a7561159" [90m-> null[0m[0m
    }

[1m  # aws_subnet.private_b[0m will be [1m[31mdestroyed[0m
[0m  [31m-[0m[0m resource "aws_subnet" "private_b" {
      [31m-[0m[0m arn                                            = "arn:aws:ec2:eu-west-1:600627358256:subnet/subnet-004552d2afad1225c" [90m-> null[0m[0m
      [31m-[0m[0m assign_ipv6_address_on_creation                = false [90m-> null[0m[0m
      [31m-[0m[0m availability_zone                              = "eu-west-1b" [90m-> null[0m[0m
      [31m-[0m[0m availability_zone_id                           = "euw1-az3" [90m-> null[0m[0m
      [31m-[0m[0m cidr_block                                     = "10.42.2.0/24" [90m-> null[0m[0m
      [31m-[0m[0m enable_dns64                                   = false [90m-> null[0m[0m
      [31m-[0m[0m enable_lni_at_device_index                     = 0 [90m-> null[0m[0m
      [31m-[0m[0m enable_resource_name_dns_a_record_on_launch    = false [90m-> null[0m[0m
      [31m-[0m[0m enable_resource_name_dns_aaaa_record_on_launch = false [90m-> null[0m[0m
      [31m-[0m[0m id                                             = "subnet-004552d2afad1225c" [90m-> null[0m[0m
      [31m-[0m[0m ipv6_native                                    = false [90m-> null[0m[0m
      [31m-[0m[0m map_customer_owned_ip_on_launch                = false [90m-> null[0m[0m
      [31m-[0m[0m map_public_ip_on_launch                        = false [90m-> null[0m[0m
      [31m-[0m[0m owner_id                                       = "600627358256" [90m-> null[0m[0m
      [31m-[0m[0m private_dns_hostname_type_on_launch            = "ip-name" [90m-> null[0m[0m
      [31m-[0m[0m region                                         = "eu-west-1" [90m-> null[0m[0m
      [31m-[0m[0m tags                                           = {
          [31m-[0m[0m "AccountId" = "600627358256"
          [31m-[0m[0m "Example"   = "s3-files"
          [31m-[0m[0m "Name"      = "s3-files-example-private-b"
        } [90m-> null[0m[0m
      [31m-[0m[0m tags_all                                       = {
          [31m-[0m[0m "AccountId" = "600627358256"
          [31m-[0m[0m "Example"   = "s3-files"
          [31m-[0m[0m "Name"      = "s3-files-example-private-b"
        } [90m-> null[0m[0m
      [31m-[0m[0m vpc_id                                         = "vpc-089cf1695a7561159" [90m-> null[0m[0m
    }

[1m  # aws_vpc.this[0m will be [1m[31mdestroyed[0m
[0m  [31m-[0m[0m resource "aws_vpc" "this" {
      [31m-[0m[0m arn                                  = "arn:aws:ec2:eu-west-1:600627358256:vpc/vpc-089cf1695a7561159" [90m-> null[0m[0m
      [31m-[0m[0m assign_generated_ipv6_cidr_block     = false [90m-> null[0m[0m
      [31m-[0m[0m cidr_block                           = "10.42.0.0/16" [90m-> null[0m[0m
      [31m-[0m[0m default_network_acl_id               = "acl-049e5aa6c30190350" [90m-> null[0m[0m
      [31m-[0m[0m default_route_table_id               = "rtb-03c9f53cd209cb328" [90m-> null[0m[0m
      [31m-[0m[0m default_security_group_id            = "sg-0add94ec365761af2" [90m-> null[0m[0m
      [31m-[0m[0m dhcp_options_id                      = "dopt-0e0ba5fe2d917d7e0" [90m-> null[0m[0m
      [31m-[0m[0m enable_dns_hostnames                 = true [90m-> null[0m[0m
      [31m-[0m[0m enable_dns_support                   = true [90m-> null[0m[0m
      [31m-[0m[0m enable_network_address_usage_metrics = false [90m-> null[0m[0m
      [31m-[0m[0m id                                   = "vpc-089cf1695a7561159" [90m-> null[0m[0m
      [31m-[0m[0m instance_tenancy                     = "default" [90m-> null[0m[0m
      [31m-[0m[0m ipv6_netmask_length                  = 0 [90m-> null[0m[0m
      [31m-[0m[0m main_route_table_id                  = "rtb-03c9f53cd209cb328" [90m-> null[0m[0m
      [31m-[0m[0m owner_id                             = "600627358256" [90m-> null[0m[0m
      [31m-[0m[0m region                               = "eu-west-1" [90m-> null[0m[0m
      [31m-[0m[0m tags                                 = {
          [31m-[0m[0m "AccountId" = "600627358256"
          [31m-[0m[0m "Example"   = "s3-files"
          [31m-[0m[0m "Name"      = "s3-files-example-vpc"
        } [90m-> null[0m[0m
      [31m-[0m[0m tags_all                             = {
          [31m-[0m[0m "AccountId" = "600627358256"
          [31m-[0m[0m "Example"   = "s3-files"
          [31m-[0m[0m "Name"      = "s3-files-example-vpc"
        } [90m-> null[0m[0m
    }

[1m  # random_pet.this[0m will be [1m[31mdestroyed[0m
[0m  [31m-[0m[0m resource "random_pet" "this" {
      [31m-[0m[0m id        = "credible-mole" [90m-> null[0m[0m
      [31m-[0m[0m length    = 2 [90m-> null[0m[0m
      [31m-[0m[0m separator = "-" [90m-> null[0m[0m
    }

[1m  # module.s3_bucket.aws_s3_bucket.this[0][0m will be [1m[31mdestroyed[0m
[0m  [31m-[0m[0m resource "aws_s3_bucket" "this" {
      [31m-[0m[0m arn                         = "arn:aws:s3:::s3-files-credible-mole" [90m-> null[0m[0m
      [31m-[0m[0m bucket                      = "s3-files-credible-mole" [90m-> null[0m[0m
      [31m-[0m[0m bucket_domain_name          = "s3-files-credible-mole.s3.amazonaws.com" [90m-> null[0m[0m
      [31m-[0m[0m bucket_namespace            = "global" [90m-> null[0m[0m
      [31m-[0m[0m bucket_region               = "eu-west-1" [90m-> null[0m[0m
      [31m-[0m[0m bucket_regional_domain_name = "s3-files-credible-mole.s3.eu-west-1.amazonaws.com" [90m-> null[0m[0m
      [31m-[0m[0m force_destroy               = true [90m-> null[0m[0m
      [31m-[0m[0m hosted_zone_id              = "Z1BKCTXD74EZPE" [90m-> null[0m[0m
      [31m-[0m[0m id                          = "s3-files-credible-mole" [90m-> null[0m[0m
      [31m-[0m[0m object_lock_enabled         = false [90m-> null[0m[0m
      [31m-[0m[0m region                      = "eu-west-1" [90m-> null[0m[0m
      [31m-[0m[0m request_payer               = "BucketOwner" [90m-> null[0m[0m
      [31m-[0m[0m tags                        = {
          [31m-[0m[0m "AccountId" = "600627358256"
          [31m-[0m[0m "Example"   = "s3-files"
        } [90m-> null[0m[0m
      [31m-[0m[0m tags_all                    = {
          [31m-[0m[0m "AccountId" = "600627358256"
          [31m-[0m[0m "Example"   = "s3-files"
        } [90m-> null[0m[0m

      [31m-[0m[0m grant {
          [31m-[0m[0m id          = "508e980d5812e435b7e39649f478fb18b183f34a42695a2e3386a1c6da42e32b" [90m-> null[0m[0m
          [31m-[0m[0m permissions = [
              [31m-[0m[0m "FULL_CONTROL",
            ] [90m-> null[0m[0m
          [31m-[0m[0m type        = "CanonicalUser" [90m-> null[0m[0m
        }

      [31m-[0m[0m server_side_encryption_configuration {
          [31m-[0m[0m rule {
              [31m-[0m[0m bucket_key_enabled = false [90m-> null[0m[0m

              [31m-[0m[0m apply_server_side_encryption_by_default {
                  [31m-[0m[0m sse_algorithm = "AES256" [90m-> null[0m[0m
                }
            }
        }

      [31m-[0m[0m versioning {
          [31m-[0m[0m enabled    = true [90m-> null[0m[0m
          [31m-[0m[0m mfa_delete = false [90m-> null[0m[0m
        }
    }

[1m  # module.s3_bucket.aws_s3_bucket_public_access_block.this[0][0m will be [1m[31mdestroyed[0m
[0m  [31m-[0m[0m resource "aws_s3_bucket_public_access_block" "this" {
      [31m-[0m[0m block_public_acls       = true [90m-> null[0m[0m
      [31m-[0m[0m block_public_policy     = true [90m-> null[0m[0m
      [31m-[0m[0m bucket                  = "s3-files-credible-mole" [90m-> null[0m[0m
      [31m-[0m[0m id                      = "s3-files-credible-mole" [90m-> null[0m[0m
      [31m-[0m[0m ignore_public_acls      = true [90m-> null[0m[0m
      [31m-[0m[0m region                  = "eu-west-1" [90m-> null[0m[0m
      [31m-[0m[0m restrict_public_buckets = true [90m-> null[0m[0m
      [31m-[0m[0m skip_destroy            = true [90m-> null[0m[0m
    }

[1m  # module.s3_bucket.aws_s3_bucket_versioning.this[0][0m will be [1m[31mdestroyed[0m
[0m  [31m-[0m[0m resource "aws_s3_bucket_versioning" "this" {
      [31m-[0m[0m bucket = "s3-files-credible-mole" [90m-> null[0m[0m
      [31m-[0m[0m id     = "s3-files-credible-mole" [90m-> null[0m[0m
      [31m-[0m[0m region = "eu-west-1" [90m-> null[0m[0m

      [31m-[0m[0m versioning_configuration {
          [31m-[0m[0m status = "Enabled" [90m-> null[0m[0m
        }
    }

[1m  # module.s3_files.aws_s3files_access_point.this["test-app-ap"][0m will be [1m[31mdestroyed[0m
[0m  [31m-[0m[0m resource "aws_s3files_access_point" "this" {
      [31m-[0m[0m arn            = "arn:aws:s3files:eu-west-1:600627358256:file-system/fs-0edb587486947d4f6/access-point/fsap-0fc85b46f1cdb99ab" [90m-> null[0m[0m
      [31m-[0m[0m file_system_id = "fs-0edb587486947d4f6" [90m-> null[0m[0m
      [31m-[0m[0m id             = "fsap-0fc85b46f1cdb99ab" [90m-> null[0m[0m
      [31m-[0m[0m owner_id       = "600627358256" [90m-> null[0m[0m
      [31m-[0m[0m region         = "eu-west-1" [90m-> null[0m[0m
      [31m-[0m[0m status         = "available" [90m-> null[0m[0m
      [31m-[0m[0m tags           = {
          [31m-[0m[0m "AccountId" = "600627358256"
          [31m-[0m[0m "Example"   = "s3-files"
        } [90m-> null[0m[0m
      [31m-[0m[0m tags_all       = {
          [31m-[0m[0m "AccountId" = "600627358256"
          [31m-[0m[0m "Example"   = "s3-files"
        } [90m-> null[0m[0m

      [31m-[0m[0m posix_user {
          [31m-[0m[0m gid = 1000 [90m-> null[0m[0m
          [31m-[0m[0m uid = 1000 [90m-> null[0m[0m
        }

      [31m-[0m[0m root_directory {
          [31m-[0m[0m path = "/test-app-data" [90m-> null[0m[0m

          [31m-[0m[0m creation_permissions {
              [31m-[0m[0m owner_gid   = 1000 [90m-> null[0m[0m
              [31m-[0m[0m owner_uid   = 1000 [90m-> null[0m[0m
              [31m-[0m[0m permissions = "0755" [90m-> null[0m[0m
            }
        }
    }

[1m  # module.s3_files.aws_s3files_file_system.this[0][0m will be [1m[31mdestroyed[0m
[0m  [31m-[0m[0m resource "aws_s3files_file_system" "this" {
      [31m-[0m[0m arn           = "arn:aws:s3files:eu-west-1:600627358256:file-system/fs-0edb587486947d4f6" [90m-> null[0m[0m
      [31m-[0m[0m bucket        = "arn:aws:s3:::s3-files-credible-mole" [90m-> null[0m[0m
      [31m-[0m[0m creation_time = "2026-05-14T18:30:52Z" [90m-> null[0m[0m
      [31m-[0m[0m id            = "fs-0edb587486947d4f6" [90m-> null[0m[0m
      [31m-[0m[0m owner_id      = "600627358256" [90m-> null[0m[0m
      [31m-[0m[0m region        = "eu-west-1" [90m-> null[0m[0m
      [31m-[0m[0m role_arn      = "arn:aws:iam::600627358256:role/s3-files-example-20260514183042483500000001" [90m-> null[0m[0m
      [31m-[0m[0m status        = "available" [90m-> null[0m[0m
      [31m-[0m[0m tags          = {
          [31m-[0m[0m "AccountId" = "600627358256"
          [31m-[0m[0m "Example"   = "s3-files"
        } [90m-> null[0m[0m
      [31m-[0m[0m tags_all      = {
          [31m-[0m[0m "AccountId" = "600627358256"
          [31m-[0m[0m "Example"   = "s3-files"
        } [90m-> null[0m[0m
    }

[1m  # module.s3_files.aws_s3files_file_system_policy.this[0][0m will be [1m[31mdestroyed[0m
[0m  [31m-[0m[0m resource "aws_s3files_file_system_policy" "this" {
      [31m-[0m[0m file_system_id = "fs-0edb587486947d4f6" [90m-> null[0m[0m
      [31m-[0m[0m policy         = jsonencode(
            {
              [31m-[0m[0m Statement = [
                  [31m-[0m[0m {
                      [31m-[0m[0m Action    = "s3files:ClientMount"
                      [31m-[0m[0m Condition = {
                          [31m-[0m[0m StringEquals = {
                              [31m-[0m[0m "aws:SourceVpc" = "vpc-089cf1695a7561159"
                            }
                        }
                      [31m-[0m[0m Effect    = "Allow"
                      [31m-[0m[0m Principal = {
                          [31m-[0m[0m AWS = "arn:aws:iam::600627358256:root"
                        }
                      [31m-[0m[0m Resource  = "*"
                      [31m-[0m[0m Sid       = "AllowAccountRootClientMount"
                    },
                ]
              [31m-[0m[0m Version   = "2012-10-17"
            }
        ) [90m-> null[0m[0m
      [31m-[0m[0m region         = "eu-west-1" [90m-> null[0m[0m
    }

[1m  # module.s3_files.aws_s3files_mount_target.this[0][0m will be [1m[31mdestroyed[0m
[0m  [31m-[0m[0m resource "aws_s3files_mount_target" "this" {
      [31m-[0m[0m availability_zone_id = "euw1-az2" [90m-> null[0m[0m
      [31m-[0m[0m file_system_id       = "fs-0edb587486947d4f6" [90m-> null[0m[0m
      [31m-[0m[0m id                   = "fsmt-0bd2267a80e1ca1d2" [90m-> null[0m[0m
      [31m-[0m[0m ipv4_address         = "10.42.1.248" [90m-> null[0m[0m
      [31m-[0m[0m network_interface_id = "eni-0221c8ccee35b2f72" [90m-> null[0m[0m
      [31m-[0m[0m owner_id             = "600627358256" [90m-> null[0m[0m
      [31m-[0m[0m region               = "eu-west-1" [90m-> null[0m[0m
      [31m-[0m[0m security_groups      = [
          [31m-[0m[0m "sg-078cf7303608c178b",
        ] [90m-> null[0m[0m
      [31m-[0m[0m status               = "available" [90m-> null[0m[0m
      [31m-[0m[0m subnet_id            = "subnet-0d590e7466f0a9d11" [90m-> null[0m[0m
      [31m-[0m[0m vpc_id               = "vpc-089cf1695a7561159" [90m-> null[0m[0m
    }

[1m  # module.s3_files.aws_s3files_mount_target.this[1][0m will be [1m[31mdestroyed[0m
[0m  [31m-[0m[0m resource "aws_s3files_mount_target" "this" {
      [31m-[0m[0m availability_zone_id = "euw1-az3" [90m-> null[0m[0m
      [31m-[0m[0m file_system_id       = "fs-0edb587486947d4f6" [90m-> null[0m[0m
      [31m-[0m[0m id                   = "fsmt-088c425c393a1c72e" [90m-> null[0m[0m
      [31m-[0m[0m ipv4_address         = "10.42.2.245" [90m-> null[0m[0m
      [31m-[0m[0m network_interface_id = "eni-0c2bb6541a33df240" [90m-> null[0m[0m
      [31m-[0m[0m owner_id             = "600627358256" [90m-> null[0m[0m
      [31m-[0m[0m region               = "eu-west-1" [90m-> null[0m[0m
      [31m-[0m[0m security_groups      = [
          [31m-[0m[0m "sg-078cf7303608c178b",
        ] [90m-> null[0m[0m
      [31m-[0m[0m status               = "available" [90m-> null[0m[0m
      [31m-[0m[0m subnet_id            = "subnet-004552d2afad1225c" [90m-> null[0m[0m
      [31m-[0m[0m vpc_id               = "vpc-089cf1695a7561159" [90m-> null[0m[0m
    }

[1mPlan:[0m 0 to add, 0 to change, 15 to destroy.
[0m
Changes to Outputs:
  [31m-[0m[0m s3_bucket_arn                               = "arn:aws:s3:::s3-files-credible-mole" [90m-> null[0m[0m
  [31m-[0m[0m s3_bucket_id                                = "s3-files-credible-mole" [90m-> null[0m[0m
  [31m-[0m[0m s3_bucket_versioning_status                 = "Enabled" [90m-> null[0m[0m
  [31m-[0m[0m s3_files_access_points                      = {
      [31m-[0m[0m test-app-ap = {
          [31m-[0m[0m arn  = "arn:aws:s3files:eu-west-1:600627358256:file-system/fs-0edb587486947d4f6/access-point/fsap-0fc85b46f1cdb99ab"
          [31m-[0m[0m id   = "fsap-0fc85b46f1cdb99ab"
          [31m-[0m[0m name = [90mnull[0m[0m
        }
    } [90m-> null[0m[0m
  [31m-[0m[0m s3_files_file_system_arn                    = "arn:aws:s3files:eu-west-1:600627358256:file-system/fs-0edb587486947d4f6" [90m-> null[0m[0m
  [31m-[0m[0m s3_files_file_system_id                     = "fs-0edb587486947d4f6" [90m-> null[0m[0m
  [31m-[0m[0m s3_files_mount_target_network_interface_ids = [
      [31m-[0m[0m "eni-0221c8ccee35b2f72",
      [31m-[0m[0m "eni-0c2bb6541a33df240",
    ] [90m-> null[0m[0m
[0m[1mmodule.s3_files.aws_s3files_file_system_policy.this[0]: Destroying...[0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[0]: Destroying... [id=fsmt-0bd2267a80e1ca1d2][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[1]: Destroying... [id=fsmt-088c425c393a1c72e][0m[0m
[0m[1mmodule.s3_files.aws_s3files_access_point.this["test-app-ap"]: Destroying... [id=fsap-0fc85b46f1cdb99ab][0m[0m
[0m[1mmodule.s3_files.aws_s3files_file_system_policy.this[0]: Destruction complete after 1s[0m
[0m[1mmodule.s3_files.aws_s3files_access_point.this["test-app-ap"]: Destruction complete after 2s[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[0]: Still destroying... [id=fsmt-0bd2267a80e1ca1d2, 10s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[1]: Still destroying... [id=fsmt-088c425c393a1c72e, 10s elapsed][0m[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[0]: Destruction complete after 15s[0m
[0m[1mmodule.s3_files.aws_s3files_mount_target.this[1]: Destruction complete after 15s[0m
[0m[1mmodule.s3_files.aws_s3files_file_system.this[0]: Destroying... [id=fs-0edb587486947d4f6][0m[0m
[0m[1mmodule.s3_files.aws_s3files_file_system.this[0]: Destruction complete after 2s[0m
[0m[1maws_iam_role_policy.s3_files_bucket_access: Destroying... [id=s3-files-example-20260514183042483500000001:s3-files-bucket-access][0m[0m
[0m[1mmodule.s3_bucket.aws_s3_bucket_versioning.this[0]: Destroying... [id=s3-files-credible-mole][0m[0m
[0m[1maws_subnet.private_a: Destroying... [id=subnet-0d590e7466f0a9d11][0m[0m
[0m[1maws_subnet.private_b: Destroying... [id=subnet-004552d2afad1225c][0m[0m
[0m[1maws_security_group.s3_files: Destroying... [id=sg-078cf7303608c178b][0m[0m
[0m[1mmodule.s3_bucket.aws_s3_bucket_public_access_block.this[0]: Destroying... [id=s3-files-credible-mole][0m[0m
[0m[1mmodule.s3_bucket.aws_s3_bucket_public_access_block.this[0]: Destruction complete after 0s[0m
[0m[1maws_iam_role_policy.s3_files_bucket_access: Destruction complete after 0s[0m
[0m[1maws_iam_role.s3_files: Destroying... [id=s3-files-example-20260514183042483500000001][0m[0m
[0m[1mmodule.s3_bucket.aws_s3_bucket_versioning.this[0]: Destruction complete after 1s[0m
[0m[1mmodule.s3_bucket.aws_s3_bucket.this[0]: Destroying... [id=s3-files-credible-mole][0m[0m
[0m[1maws_iam_role.s3_files: Destruction complete after 1s[0m
[0m[1maws_subnet.private_b: Destruction complete after 1s[0m
[0m[1mmodule.s3_bucket.aws_s3_bucket.this[0]: Destruction complete after 1s[0m
[0m[1mrandom_pet.this: Destroying... [id=credible-mole][0m[0m
[0m[1mrandom_pet.this: Destruction complete after 0s[0m
[0m[1maws_subnet.private_a: Destruction complete after 2s[0m
[0m[1maws_security_group.s3_files: Destruction complete after 2s[0m
[0m[1maws_vpc.this: Destroying... [id=vpc-089cf1695a7561159][0m[0m
[0m[1maws_vpc.this: Destruction complete after 1s[0m
[0m[1m[32m
Destroy complete! Resources: 15 destroyed.
[0m