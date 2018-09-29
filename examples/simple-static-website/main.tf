provider "aws" {
    region = "eu-west-1"
}

module "simple_s3_bucket" {
    source = "../../"

    name = "simple-bucket"
    tags = {
        Owner       = "Krisjanis Veinbahs"
        Environment = "Development"
    }
}
