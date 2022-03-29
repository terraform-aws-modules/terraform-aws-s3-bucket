module "wrapper" {
  source = "../../modules/notification"

  for_each = var.items

  create               = try(each.value.create, true)
  create_sns_policy    = try(each.value.create_sns_policy, true)
  create_sqs_policy    = try(each.value.create_sqs_policy, true)
  bucket               = try(each.value.bucket, "")
  bucket_arn           = try(each.value.bucket_arn, null)
  eventbridge          = try(each.value.eventbridge, null)
  lambda_notifications = try(each.value.lambda_notifications, {})
  sqs_notifications    = try(each.value.sqs_notifications, {})
  sns_notifications    = try(each.value.sns_notifications, {})
}
