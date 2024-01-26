module "wrapper" {
  source = "../../modules/notification"

  for_each = var.items

  bucket               = try(each.value.bucket, var.defaults.bucket, "")
  bucket_arn           = try(each.value.bucket_arn, var.defaults.bucket_arn, null)
  create               = try(each.value.create, var.defaults.create, true)
  create_sns_policy    = try(each.value.create_sns_policy, var.defaults.create_sns_policy, true)
  create_sqs_policy    = try(each.value.create_sqs_policy, var.defaults.create_sqs_policy, true)
  eventbridge          = try(each.value.eventbridge, var.defaults.eventbridge, null)
  lambda_notifications = try(each.value.lambda_notifications, var.defaults.lambda_notifications, {})
  sns_notifications    = try(each.value.sns_notifications, var.defaults.sns_notifications, {})
  sqs_notifications    = try(each.value.sqs_notifications, var.defaults.sqs_notifications, {})
}
