# terraform-aws-s3-bucket
Terraform module which creates S3 bucket resources on AWS

These S3 Bucket configurations are supported:

- cors
- lifecycle-rules
- logging
- replication (Cross Region Replication - CRR)*
- versioning
- website

```
These configurations are not supported yet:

In Cross Region Replication (in replication_configuration/rules block):
- priority (the argument is not supported yet).
- filter (the argument is not supported yet).

Object Lock Configuration block(object_lock_configuration) (this configuration block is not supported yet).
```

# Usage:

- **Private Bucket**

```
  module "my_bucket" {
  source = "../.."
  bucket = "my-tf-test-bucket"
  acl    = "private"
}
```

# Examples:

* [S3-CORS](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/master/examples/s3-cors)
* [S3-Lifecycle-Rules](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/master/examples/s3-lifecycle-rules)
* [S3-Logging](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/master/examples/s3-logging)
* [S3-Replication](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/master/examples/s3-replication)
* [S3-Versioning](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/master/examples/s3-versioning)
* [S3-Website](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/master/examples/s3-website)

# Inputs notes:
```
The Terraform "aws_s3_bucket" resource has some nested configuration blocks and this was translated
to this module as lists of objects. Each configuration block was renamed as it follows: 
<CONFIG_BLOCK_NAME>_inputs
``` 
  

```
module "aws_s3_bucket" {
  source = "../.."
  bucket = "s3-tf-example-logging"
  acl    = "private"

  logging_inputs = [
  {
    target_bucket = "s3-tf-example-logger"
    target_prefix = "log/"
  },
  ]
```
The **logging_inputs** list will be converted to a **logging** configuration block:
```
logging {
  target_bucket = "s3-tf-example-logger"
  target_prefix = "log/"
}
```
# Inputs:
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| bucket | (Forces new resource) The name of the bucket. If omitted, Terraform will assign a random, unique name. | string | null | no | 
| bucket_prefix | (Forces new resource) Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket. | string | null | no |
| acl | The canned ACL to apply. Defaults to "private". | string | null | no |
| policy | A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide | string | null | no |
| tags | A mapping of tags to assign to the bucket. | map | null | no |
| force_destroy | A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable. | boolean | false | no |
| website_inputs | A website object (documented below). | list(object) | null | no | 
| cors_rule_inputs | A rule of Cross-Origin Resource Sharing (documented below). | list(object) | null | no | 
| versioning_inputs | A state of versioning (documented below) | list(object) | null | no | 
| logging_inputs | A settings of bucket logging (documented below). | list(object) | null | no | 
| lifecycle_rule_inputs | A configuration of object lifecycle management (documented below). | list(object) | null | no | 
| acceleration_status | Sets the accelerate configuration of an existing bucket. Can be Enabled or Suspended. | string | null | no | 
| region | If specified, the AWS region this bucket should reside in. Otherwise, the region used by the callee. | string | null | no | 
| request_payer | Specifies who should bear the cost of Amazon S3 data transfer. Can be either BucketOwner or Requester. By default, the owner of the S3 bucket would incur the costs of any data transfer. See Requester Pays Buckets developer guide for more information. | string | null | no |
| replication_configuration_inputs | A configuration of replication configuration (documented below). | list(object) | null | no |
| server_side_encryption_configuration_inputs | A configuration of server-side encryption configuration (documented below) | list(object) | null | no |
| **object_lock_configuration_inputs** | **(Not implemented yet)** A configuration of S3 object locking (documented below) | list(object) | null | no |


# website_inputs:
| Name | Description | Type | Required | 
|------|-------------|:----:|:-----:|
| index_document | Amazon S3 returns this index document when requests are made to the root domain or any of the subfolders. | string | yes (unless using redirect_all_requests_to) |
| error_document | An absolute path to the document to return in case of a 4XX error. | string | no |
| redirect_all_requests_to | A hostname to redirect all website requests for this bucket to. Hostname can optionally be prefixed with a protocol (http:// or https://) to use when redirecting requests. The default is the protocol that is used in the original request. | string | no |
| routing_rules | A json array containing routing rules describing redirect behavior and when redirects are applied. | string | no | 

# cors_rule_inputs:
| Name | Description | Type | Required |
|------|-------------|:----:|:-----:|
| allowed_headers | Specifies which headers are allowed. | list(string) | no |
| allowed_methods | Specifies which methods are allowed. Can be GET, PUT, POST, DELETE or HEAD. | list(string) | yes |
| allowed_origins | Specifies which origins are allowed. | list(string) | yes |
| expose_headers | Specifies expose header in the response. | list(string) | no |
| max_age_seconds | Specifies time in seconds that browser can cache the response for a preflight request.  | number | no |'

# versioning_inputs
| Name | Description | Type | Required |
|------|-------------|:----:|:-----:|
| enabled | Enable versioning. Once you version-enable a bucket, it can never return to an unversioned state. You can, however, suspend versioning on that bucket. | boolean | no |
| mfa_delete | Enable MFA delete for either Change the versioning state of your bucket or Permanently delete an object version. Default is false. | boolean | no |

# logging_inputs
| Name | Description | Type | Required |
|------|-------------|:----:|:-----:|
| target_bucket| The name of the bucket that will receive the log objects. | string | yes |
| target_prefix | To specify a key prefix for log objects. | string | no |

---

# lifecycle_rule_inputs
| Name | Description | Type | Required |
|------|-------------|:----:|:-----:|
| id | Unique identifier for the rule. | string | no |
| prefix | Object key prefix identifying one or more objects to which the rule applies. | string | no |
| tags | Specifies object tags key and value. | map | no |
| enabled | Specifies lifecycle rule status. | boolean | yes |
| abort_incomplete_multipart_upload_days | Specifies the number of days after initiating a multipart upload when the multipart be  completed. | number | no | 
| expiration_inputs | Specifies a period in the object's expire (documented below). | list(object) | no |
| transition_inputs | Specifies a period in the object's transitions (documented below). | list(object) | no |
| noncurrent_version_expiration_inputs | Specifies when noncurrent object versions expire (documented below). | list(object) | no |
| noncurrent_version_transition_inputs | Specifies when noncurrent object versions transitions (documented below).  | list(object) | no |

# lifecycle_rule_inputs/expiration_inputs:
| Name | Description | Type | Required |
|------|-------------|:----:|:-----:|
| date | Specifies the date after which you want the corresponding action to take effect. | string | no |
| days | Specifies the number of days after object creation when the specific rule action takes effect. | string | no |
| expired_object_delete_marker | On a versioned bucket (versioning-enabled or versioning-suspended bucket), you can add this element in the lifecycle configuration to direct Amazon S3 to delete expired object delete markers. | string | no |

# lifecycle_rule_inputs/transition_inputs:
| Name | Description | Type | Required |
|------|-------------|:----:|:-----:|
| date | Specifies the date after which you want the corresponding action to take effect. | string | no |
| days | Specifies the number of days after object creation when the specific rule action takes effect. | string | no |
| storage_class | Specifies the Amazon S3 storage class to which you want the object to transition. Can be ONEZONE_IA, STANDARD_IA, INTELLIGENT_TIERING, or GLACIER. | string | yes |

# lifecycle_rule_inputs/noncurrent_version_expiration:
| Name | Description | Type | Required |
|------|-------------|:----:|:-----:|
| days | Specifies the number of days after object creation when the specific rule action takes effect. | string | yes |

# lifecycle_rule_inputs/noncurrent_version_transition:
| Name | Description | Type | Required |
|------|-------------|:----:|:-----:|
| days | Specifies the number of days after object creation when the specific rule action takes effect. | string | yes |
| storage_class | Specifies the Amazon S3 storage class to which you want the object to transition. Can be ONEZONE_IA, STANDARD_IA, INTELLIGENT_TIERING, or GLACIER. | string | yes |

---

# replication_configuration_inputs
| Name | Description | Type | Required |
|------|-------------|:----:|:-----:|
| role | The ARN of the IAM role for Amazon S3 to assume when replicating the objects. | string | yes |
| rules_inputs | Specifies the rules managing the replication (documented below).  | list(object) | yes |

# replication_configuration_inputs/rules_inputs:
| Name | Description | Type | Required |
|------|-------------|:----:|:-----:|
| id | Unique identifier for the rule.| string | no |
| destination | Specifies the destination for the rule (documented below).| list(object) | yes |
| source_selection_criteria | Specifies special object selection criteria (documented below).| list(object) | no |
| prefix | Object keyname prefix identifying one or more objects to which the rule applies.| string | no |
| status | The status of the rule. Either Enabled or Disabled. The rule is ignored if status is not Enabled.| string | yes |

<!--| priority | The priority associated with the rule.| string | no |-->
<!--| filter | Filter that identifies subset of objects to which the replication rule applies (documented below). | string | no |-->

# replication_configuration_inputs/rules_inputs/destination_inputs:
| Name | Description | Type | Required |
|------|-------------|:----:|:-----:|
| bucket | The ARN of the S3 bucket where you want Amazon S3 to store replicas of the object identified by the rule. | string | yes |
| storage_class | The class of storage used to store the object. Can be STANDARD, REDUCED_REDUNDANCY, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, or GLACIER. | string | no |
| replica_kms_key_id | Destination KMS encryption key ARN for SSE-KMS replication. Must be used in conjunction with sse_kms_encrypted_objects source selection criteria. | string | no |
| access_control_translation | Specifies the overrides to use for object owners on replication. Must be used in conjunction with account_id owner override configuration. | list(object) | no |
| account_id | The Account ID to use for overriding the object owner on replication. Must be used in conjunction with access_control_translation override configuration. | string | no | 

# replication_configuration_inputs/rules_inputs/destination_inputs/access_control_translation_inputs:
| Name | Description | Type | Required |
|------|-------------|:----:|:-----:|
| owner | The override value for the owner on replicated objects. Currently only Destination is supported. | string | yes | 

# replication_configuration_inputs/rules_inputs/source_selection_criteria_inputs:
| Name | Description | Type | Required |
|------|-------------|:----:|:-----:|
| enabled | Boolean which indicates if this criteria is enabled.(It refers to _sse_kms_encrypted_objects/enabled_ config.) | boolean | yes |

---

# server_side_encryption_configuration_inputs:
| Name | Description | Type | Required |
|------|-------------|:----:|:-----:|
| sse_algorithm | The server-side encryption algorithm to use. Valid values are AES256 and aws:kms (It refers to server_side_encryption_configuration/rule/apply_server_side_encryption_by_default/sse_algorithm ) | string | yes |
| kms_master_key_id | The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms. The default aws/s3 AWS KMS master key is used if this element is absent while the sse_algorithm is aws:kms. (It refers to server_side_encryption_configuration/rule/apply_server_side_encryption_by_default/kms_master_key_id ) | string | no |

# outputs
| Name | Description |
|------|-------------|
| id | The name of the bucket. |
| arn | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname. |
| bucket_domain_name | The bucket domain name. Will be of format bucketname.s3.amazonaws.com. |
| bucket_regional_domain_name | The bucket region-specific domain name. The bucket domain name including the region name, please refer here for format. Note: The AWS CloudFront allows specifying S3 region-specific endpoint when creating S3 origin, it will prevent redirect issues from CloudFront to S3 Origin URL. |
| hosted_zone_id | The Route 53 Hosted Zone ID for this bucket's region. |
| region | The AWS region this bucket resides in. |
| website_endpoint | The website endpoint, if the bucket is configured with a website. If not, this will be an empty string. |
| website_domain | The domain of the website endpoint, if the bucket is configured with a website. If not, this will be an empty string. This is used to create Route 53 alias records.