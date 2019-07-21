variable "region" {
  default = "ca-central-1"
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

module "bucket" {
  source = "../.."
  bucket = "s3-tf-example-replication"
  acl    = "private"

  versioning_inputs = [
    {
      enabled    = true
      mfa_delete = null
    },
  ]

  replication_configuration_inputs = [
    {
      role = "<ROLE_ARN>" // Place the IAM Role to access the destination bucket

      rules_inputs = [
        {
          id                               = "foobar"
          prefix                           = "foo"
          status                           = "Enabled"
          priority                         = null
          source_selection_criteria_inputs = null
          filter_inputs                    = null

          destination_inputs = [
            {
              bucket                            = "<DESTINATION_BUCKET>" // Place the destination bicket ARN
              storage_class                     = "STANDARD"
              replica_kms_key_id                = null
              account_id                        = null
              access_control_translation_inputs = null
            },
          ]
        },
      ]
    },
  ]
}
