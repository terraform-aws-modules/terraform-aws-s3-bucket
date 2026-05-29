locals {
  region = "eu-west-1"
}

provider "aws" {
  region = local.region
}

data "aws_caller_identity" "current" {}

resource "random_pet" "this" {
  length = 2
}

# https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-vectors-data-encryption.html
module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 3.0"

  description             = "KMS key for S3 Vectors encryption"
  deletion_window_in_days = 7

  key_statements = [
    {
      sid = "AllowS3VectorsServicePrincipal"
      actions = [
        "kms:Decrypt",
        "kms:GenerateDataKey",
      ]
      resources = ["*"]

      principals = [
        {
          type        = "Service"
          identifiers = ["indexing.s3vectors.amazonaws.com"]
        },
      ]

      conditions = [
        {
          test     = "ArnLike"
          variable = "aws:SourceArn"
          values = [
            "arn:aws:s3vectors:${local.region}:${data.aws_caller_identity.current.account_id}:bucket/*",
          ]
        },
        {
          test     = "StringEquals"
          variable = "aws:SourceAccount"
          values = [
            data.aws_caller_identity.current.account_id,
          ]
        },
        {
          test     = "ForAnyValue:StringEquals"
          variable = "kms:EncryptionContextKeys"
          values = [
            "aws:s3vectors:arn",
            "aws:s3vectors:resource-id",
          ]
        },
      ]
    },
  ]
}

module "vector_bucket" {
  source = "../../modules/vectors"

  vector_bucket_name = random_pet.this.id

  encryption_configuration = {
    sse_type    = "aws:kms"
    kms_key_arn = module.kms.key_arn
  }

  create_policy = true
  policy        = data.aws_iam_policy_document.vector_bucket_policy.json

  tags = {
    Example = "vectors"
  }
}

module "vector_bucket_with_index" {
  source = "../../modules/vectors"

  vector_bucket_name = "${random_pet.this.id}-with-index"

  encryption_configuration = {
    sse_type    = "aws:kms"
    kms_key_arn = module.kms.key_arn
  }

  indexes = {
    embeddings = {
      index_name      = "embeddings"
      dimension       = 1536
      distance_metric = "cosine"

      encryption_configuration = {
        sse_type    = "aws:kms"
        kms_key_arn = module.kms.key_arn
      }

      metadata_configuration = {
        non_filterable_metadata_keys = ["description", "source_url"]
      }

      tags = {
        Example = "vectors-with-index"
      }
    }
    images = {
      index_name      = "images"
      dimension       = 2048
      distance_metric = "euclidean"
      data_type       = "float32"

      encryption_configuration = {
        sse_type    = "aws:kms"
        kms_key_arn = module.kms.key_arn
      }
    }
  }

  tags = {
    Example = "vectors-with-index"
  }
}

data "aws_iam_policy_document" "vector_bucket_policy" {
  statement {
    sid    = "WriteAccess"
    effect = "Allow"

    actions = [
      "s3vectors:CreateIndex",
      "s3vectors:ListIndexes",
      "s3vectors:QueryVectors",
      "s3vectors:PutVectors",
      "s3vectors:DeleteIndex",
      "s3vectors:DeleteVectors",
    ]

    resources = [
      module.vector_bucket.vector_bucket_arn,
      "${module.vector_bucket.vector_bucket_arn}/index/*",
    ]

    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
      type        = "AWS"
    }
  }

  statement {
    sid    = "ReadAccess"
    effect = "Allow"

    actions = [
      "s3vectors:ListIndexes",
      "s3vectors:GetVectors",
      "s3vectors:QueryVectors",
    ]

    resources = [
      module.vector_bucket.vector_bucket_arn,
      "${module.vector_bucket.vector_bucket_arn}/index/*",
    ]

    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
      type        = "AWS"
    }
  }
}
