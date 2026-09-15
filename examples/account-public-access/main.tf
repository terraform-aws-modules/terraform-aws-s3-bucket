provider "aws" {
  region = local.region
}

locals {
  region = "eu-west-1"
}

data "aws_caller_identity" "this" {}

################################################################################
# Account Public Access Block
################################################################################

module "account_public_access" {
  source = "../../modules/account-public-access"

  account_id = data.aws_caller_identity.this.account_id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

################################################################################
# Disabled
################################################################################

module "disabled" {
  source = "../../modules/account-public-access"

  create = false
}
