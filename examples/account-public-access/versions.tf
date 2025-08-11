terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.5"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.0"
    }
  }
}
