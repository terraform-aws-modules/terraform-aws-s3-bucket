provider "aws" {
  region = local.region
}

locals {
  region = "eu-west-1"
  name   = "ex-${basename(path.cwd)}"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  # One mount target per Availability Zone, keyed by the zone name so the keys are known at plan time
  mount_targets = { for az, subnet_id in zipmap(local.azs, module.vpc.private_subnets) : az => { subnet_id = subnet_id } }

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-s3-bucket"
  }
}

data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

################################################################################
# S3 Bucket
################################################################################

module "s3_bucket" {
  source = "../../"

  bucket_prefix = "${local.name}-"

  # For example only
  force_destroy = true

  versioning = {
    enabled = true
  }

  file_systems = {
    training = {
      prefix        = "training/"
      mount_targets = local.mount_targets

      # Training jobs read the dataset but never write to it
      policy_statements = [{
        sid     = "ReadOnlyClients"
        actions = ["s3files:ClientMount"]
        principals = [{
          type        = "AWS"
          identifiers = [module.client_role.arn]
        }]
      }]

      synchronization_configuration = {
        # Preload files under 10 MiB and expire them after 3 days without access
        import_data_rule = [{
          prefix         = "training/"
          size_less_than = 10485760
          trigger        = "ON_DIRECTORY_FIRST_ACCESS"
        }]
        expiration_data_rule = {
          days_after_last_access = 3
        }
      }
    }

    agents = {
      prefix          = "agents/"
      mount_targets   = local.mount_targets
      security_groups = [module.agents_security_group.id]

      access_points = {
        app = {
          posix_user = {
            uid = 1000
            gid = 1000
          }
          root_directory = {
            path = "/app"
            creation_permissions = {
              owner_uid   = 1000
              owner_gid   = 1000
              permissions = "755"
            }
          }
          read_write_access_arns = [module.client_role.arn]
        }
        reports = {
          root_directory = {
            path = "/reports"
            creation_permissions = {
              owner_uid   = 1000
              owner_gid   = 1000
              permissions = "755"
            }
          }
          read_access_arns = [module.client_role.arn]
        }
      }

      synchronization_configuration = {
        # Agents read metadata only, file data is always served from S3
        import_data_rule = [{
          prefix         = "agents/"
          size_less_than = 0
          trigger        = "ON_DIRECTORY_FIRST_ACCESS"
        }]
        expiration_data_rule = {
          days_after_last_access = 30
        }
      }
    }
  }

  file_system_security_group_name            = "${local.name}-mount-targets"
  file_system_security_group_use_name_prefix = false
  file_system_security_group_description     = "S3 Files mount targets"
  file_system_security_group_vpc_id          = module.vpc.vpc_id
  file_system_security_group_ingress_rules = {
    clients = {
      referenced_security_group_id = module.client_security_group.id
    }
  }
  file_system_security_group_tags = {
    Purpose = "s3-files"
  }

  tags = local.tags
}

################################################################################
# Disabled
################################################################################

module "disabled" {
  source = "../../"

  create_bucket = false

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]

  tags = local.tags
}

module "client_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 6.0"

  name        = "${local.name}-client"
  description = "Compute that mounts the S3 file systems"
  vpc_id      = module.vpc.vpc_id

  egress_rules = {
    nfs = {
      from_port = 2049
      to_port   = 2049
      cidr_ipv4 = module.vpc.vpc_cidr_block
    }
  }

  tags = local.tags
}

module "agents_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 6.0"

  name        = "${local.name}-agents"
  description = "Mount targets of the agents S3 file system"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = {
    clients = {
      from_port                    = 2049
      to_port                      = 2049
      referenced_security_group_id = module.client_security_group.id
    }
  }

  tags = local.tags
}

module "client_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "~> 6.0"

  name = "${local.name}-client"

  trust_policy_permissions = {
    LambdaAssumeRole = {
      actions = ["sts:AssumeRole"]
      principals = [{
        type        = "Service"
        identifiers = ["lambda.amazonaws.com"]
      }]
    }
  }

  tags = local.tags
}
