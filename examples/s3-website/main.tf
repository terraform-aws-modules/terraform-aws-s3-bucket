variable "region" {
  default = "us-west-2"
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

// Calling module:

module "aws_s3_bucket" {
  source = "../.."
  bucket = "s3-tf-example-website"
  acl    = "private"

  website_inputs = [
    {
      index_document           = "index.html"
      error_document           = "error.html"
      redirect_all_requests_to = null
      routing_rules            = <<EOF
    [{
    "Condition": {
        "KeyPrefixEquals": "docs/"
    },
    "Redirect": {
        "ReplaceKeyPrefixWith": "documents/"
    } 
    }]
    EOF
    }
  ]


}