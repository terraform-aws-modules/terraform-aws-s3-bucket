terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.42"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 2.0"
    }
  }
}
