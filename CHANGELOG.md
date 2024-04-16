# Changelog

All notable changes to this project will be documented in this file.

## [4.1.2](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v4.1.1...v4.1.2) (2024-04-16)


### Bug Fixes

* Typo in description of `access_log_delivery_policy_source_buckets` variable ([#278](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/278)) ([b4a5347](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/b4a5347feb4120a6872c4aade8e50585aeb86e7c))

## [4.1.1](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v4.1.0...v4.1.1) (2024-03-06)


### Bug Fixes

* Update CI workflow versions to remove deprecated runtime warnings ([#274](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/274)) ([ca372ac](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/ca372acbc82e6f8e16ff810a9f1b4a5ae52230b5))

## [4.1.0](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v4.0.1...v4.1.0) (2024-01-26)


### Features

* Allow override of the default tags override ([#261](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/261)) ([f9e1740](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/f9e1740cafe597f2764a0d2ee7dbd34a0e19753c))

### [4.0.1](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v4.0.0...v4.0.1) (2024-01-13)


### Bug Fixes

* Fixed routing rule condition ([#270](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/270)) ([116f79b](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/116f79be982b02c3f14dd92a8694d214dc81b3f5))

## [4.0.0](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v3.15.2...v4.0.0) (2024-01-13)


### ⚠ BREAKING CHANGES

* upd versions.tf to require >= 5.27

### Features

* **logging:** change logging variable type to any ([2c45bde](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/2c45bdeb097cac250c395ed6dfb7c091e5f54abd))
* **logging:** Date based partitioning for access-logs ([59f65af](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/59f65afbc5050a6c651b51d41180f64de71478dc))
* upd versions.tf to require >= 5.27 ([7a4aab6](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/7a4aab6d27a5d09404f517a5ef419898e0ce2281))

### [3.15.2](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v3.15.1...v3.15.2) (2024-01-12)


### Bug Fixes

* Add China regions to elb_service_accounts ([#264](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/264)) ([c6870d5](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/c6870d5187eaa83d089ebeb7d1e750217da4ec89))

### [3.15.1](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v3.15.0...v3.15.1) (2023-08-26)


### Bug Fixes

* Added missing check for attach_access_log_delivery_policy for access logs logic ([#252](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/252)) ([97e542b](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/97e542bbcece748602ea46fd5e136f64a0064dac))

## [3.15.0](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v3.14.1...v3.15.0) (2023-08-22)


### Features

* Stop requiring `s3:ListAllMyBuckets` IAM permission unless needed (for bucket ACL) ([#243](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/243)) ([74fcc60](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/74fcc607d21bdd34c2daf3a3ca997c7c0c1c4dde))

### [3.14.1](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v3.14.0...v3.14.1) (2023-07-19)


### Bug Fixes

* Update log delivery policy to add `s3:ListBucket` action ([#245](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/245)) ([af0a28d](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/af0a28d70b8722e77ecf16c15a2b029105074934))

## [3.14.0](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v3.13.0...v3.14.0) (2023-06-19)


### Features

* Add "deny incorrect kms key sse" bucket policy ([#240](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/240)) ([e0d5788](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/e0d5788f7884280f66c62734127efa7661462640))

## [3.13.0](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v3.12.0...v3.13.0) (2023-06-11)


### Features

* Add "deny unencrypted object uploads" and "incorrect encryption headers" bucket policies ([#238](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/238)) ([2542a36](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/2542a36f2d85cba2996a348c70b5c7b6d523b675))

## [3.12.0](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v3.11.0...v3.12.0) (2023-06-08)


### Features

* Allow setting id parameter in notification object ([#236](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/236)) ([f9067dc](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/f9067dca08248d90c24a8b664aa006bc356dcc98))

## [3.11.0](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v3.10.1...v3.11.0) (2023-05-25)


### Features

* Added outputs for s3 bucket lifecycle rules and policy ([#234](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/234)) ([24b88e8](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/24b88e8ec1b02c48f49b5eb04d7ccda8569cde1e))

### [3.10.1](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v3.10.0...v3.10.1) (2023-04-28)


### Bug Fixes

* Fixed Bucket Policy chain dependency with Public Access Block ([#227](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/227)) ([fa19074](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/fa190740956fc2efab0d94c8e60b3d3c63d0ddd3))

## [3.10.0](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v3.9.0...v3.10.0) (2023-04-27)


### Features

* Add default Access Log Delivery Policy (same as ALB/NLB) to work since April 2023 ([#230](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/230)) ([bafac30](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/bafac30bb577ead366fd0b1ab759b0c2a2f4bc5d))

## [3.9.0](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v3.8.2...v3.9.0) (2023-04-26)


### Features

* Updated S3 Bucket Block Public Access and ACL(Object Ownership) defaults to work since April 2023 ([#226](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/226)) ([12ad5b6](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/12ad5b667b7b6556390e6c49a9719457d2742e03))

### [3.8.2](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v3.8.1...v3.8.2) (2023-03-10)


### Bug Fixes

* Fixed ELB log delivery policy for old and new regions ([#219](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/219)) ([3c094b3](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/3c094b32333a177a07477c4079ef3bd8cc56eea8))

### [3.8.1](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v3.8.0...v3.8.1) (2023-03-10)


### Bug Fixes

* Fixed the issue with ACLs configuration update ([#202](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/202)) ([2aa607d](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/2aa607d623d529a39bd480ba9dc8d1d0da519f8d))

## [3.8.0](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v3.7.0...v3.8.0) (2023-03-10)


### Features

* Added new S3 bucket policy statement for latest regions ([#218](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/218)) ([b04894f](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/b04894f2d1ec4faaf82dd8b2a871c95481928a60))

## [3.7.0](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v3.6.1...v3.7.0) (2023-02-10)


### Features

* Adding analytics configuration support ([#193](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/193)) ([fd62dbc](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/fd62dbc0f111dd99552d5892ee26fe730445942e))

### [3.6.1](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v3.6.0...v3.6.1) (2023-01-24)


### Bug Fixes

* Use a version for  to avoid GitHub API rate limiting on CI workflows ([#204](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/204)) ([769f2f6](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/769f2f6213f1851ff72d7939b9b8c5fd35c35111))

## [3.6.0](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v3.5.0...v3.6.0) (2022-11-11)


### Features

* Add inventory config support ([#192](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/192)) ([8836d0f](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/8836d0f19b23bf36e9c250307e4f4858a5cb3f4c))

## [3.5.0](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v3.4.1...v3.5.0) (2022-10-29)


### Features

* Add bucket metrics support ([#190](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/190)) ([65ed0fb](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/65ed0fbf8db52ea6f2ad7c86afa1719a417c0e46))

### [3.4.1](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v3.4.0...v3.4.1) (2022-10-27)


### Bug Fixes

* Update CI configuration files to use latest version ([#188](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/188)) ([e26dc4f](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/e26dc4f8f5bb6e78e8729b0524b105f38b11e720))

## [3.4.0](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v3.3.1...v3.4.0) (2022-08-26)


### Features

* Added source_hash parameter to modules/object ([#178](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/178)) ([6cf4584](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/6cf45848d014f737e5580fc1b2d9dbd8469e0529))

### [3.3.1](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v3.3.0...v3.3.1) (2022-08-26)


### Bug Fixes

* Remove deprecated attributes from ignore_changes ([#179](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/179)) ([8366ccc](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/8366cccab085e73f794af1e2f4ec4d1abd240806))

## [3.3.0](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v3.2.4...v3.3.0) (2022-06-17)


### Features

* Add the intelligent tiering configuration ([#167](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/167)) ([73c48d6](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/73c48d64b26f44ba13dc8113fbf084ef444f3338))

### [3.2.4](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v3.2.3...v3.2.4) (2022-06-14)


### Bug Fixes

* Remove hardcoded aws partition in notifications sub-module ([#165](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/165)) ([c51db21](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/c51db21c7dd0f177dae890a108f625bffe4320f6))

### [3.2.3](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v3.2.2...v3.2.3) (2022-05-25)


### Bug Fixes

* Revert change for grant in aws_s3_bucket_acl resource ([#164](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/164)) ([ec88013](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/ec88013616a049434aad08590bbf478f2e05c597))

### [3.2.2](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v3.2.1...v3.2.2) (2022-05-25)


### Bug Fixes

* Fixed issue with multiple grants in aws_s3_bucket_acl ([#163](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/163)) ([9ed6eaa](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/9ed6eaae0c2d5786275ae4199bd5b02135125fcf))

### [3.2.1](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v3.2.0...v3.2.1) (2022-05-18)


### Bug Fixes

* Allow setup eventbridge without notifications ([#160](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/160)) ([31b8e9d](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/31b8e9dcd1793e77b1cd0242a42d7b0abee66b4e))

## [3.2.0](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v3.1.1...v3.2.0) (2022-05-04)


### Features

* Added wrappers automatically generated via hook ([#156](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/156)) ([3634462](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/363446280bfd0a4ed56d07c6538bf9e3e92c6c0e))

### [3.1.1](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v3.1.0...v3.1.1) (2022-04-26)


### Bug Fixes

* Key `host_name` on website routing rules redirect ([#152](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/152)) ([3ca8327](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/3ca83273992c7083a91a2d5c74b4b91e5c9add79))

## [3.1.0](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v3.0.1...v3.1.0) (2022-04-15)


### Features

* Upgraded AWS provider to 4.5, fixed object_lock_enabled ([#149](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/149)) ([70d08fd](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/70d08fd4e6d0c1977ffe423e2b9e675c8fb38235))

### [3.0.1](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v3.0.0...v3.0.1) (2022-04-02)


### Bug Fixes

* Add lifecycle ignore changes on s3_bucket resource to prevent configuration loop ([#145](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/145)) ([895cfa5](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/895cfa529ed0162f4f12f1e99f2f2b14bb262072))

## [3.0.0](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v2.15.0...v3.0.0) (2022-03-30)


### ⚠ BREAKING CHANGES

* Update to support AWS provider v3.75 and newer (including v4.x) (#139)

### Features

* Update to support AWS provider v3.75 and newer (including v4.x) ([#139](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/139)) ([e0de434](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/e0de434f2213518d6c2c9c710dd1bb3fd0eaf46d))

## [2.15.0](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v2.14.1...v2.15.0) (2022-03-12)


### Features

* Made it clear that we stand with Ukraine ([cad9118](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/cad911829d74bab4b594d7ad7944f93f8aef1f34))

### [2.14.1](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v2.14.0...v2.14.1) (2022-02-10)


### Bug Fixes

* Pin version to v3 due to number of breaking changes in v4 ([#136](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/136)) ([7dd9a65](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/7dd9a655e5654291e29332b6f43c8065ad60a11b))

## [2.14.0](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v2.13.0...v2.14.0) (2022-02-10)


### Features

* Added source_account for lambda_permission resource ([#135](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/135)) ([e9f0fcc](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/e9f0fcc5aaa90d19fd93800fc9bb99b270546f13))


### Bug Fixes

* Changelog duplicate header ([#133](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/133)) ([8d4d28e](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/8d4d28e051cbe48356f63c05ba678d2750c94b8d))

## [2.13.0](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v2.12.0...v2.13.0) (2022-01-15)


### Features

* Added optional bucket policy for requiring TLS 1.2 ([#126](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/126)) ([c56c684](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/c56c684a9cc148ad1bad9883514b6e4ec2c4c67a))

## [2.12.0](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v2.11.2...v2.12.0) (2022-01-12)


### Features

* Update object_ownership variable description ([#121](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/121)) ([ce9e719](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/ce9e719082c42db0560ad77a703cee5ee780e9a4))

### [2.11.2](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v2.11.1...v2.11.2) (2022-01-10)


### Bug Fixes

* update CI/CD process to align auto-release workflow configs ([#118](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/118)) ([31d76f9](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/31d76f933b05848be9aaf25befd43966e4065472))

## [2.11.1](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v2.11.0...v2.11.1) (2021-11-07)


### Bug Fixes

* update CI/CD process to enable auto-release workflow ([#116](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/116)) ([1b7ac99](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/1b7ac9958150f43f251e6cad4fffa493c22c4c68))

<a name="v2.11.0"></a>
## [v2.11.0] - 2021-11-07

- chore: Update CI workflow to use composite actions and update pre-commit versions ([#115](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/115))
- feat: Added Replication Time Control for Bucket Replication ([#114](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/114))


<a name="v2.10.0"></a>
## [v2.10.0] - 2021-10-29

- feat: Replace hardcoded cloudfront canonical user ID in example ([#113](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/113))


<a name="v2.9.0"></a>
## [v2.9.0] - 2021-08-27

- feat: Added delete marker in replication rules ([#108](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/108))


<a name="v2.8.0"></a>
## [v2.8.0] - 2021-08-26

- feat: Added support for S3 bucket object ownership ([#101](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/101))


<a name="v2.7.0"></a>
## [v2.7.0] - 2021-08-13

- fix: Always send `filter` map in replication config ([#105](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/105))


<a name="v2.6.0"></a>
## [v2.6.0] - 2021-06-28

- docs: Updated examples for ALB/NLB logs


<a name="v2.5.0"></a>
## [v2.5.0] - 2021-06-18

- chore: Updated string interpolation in resource ([#97](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/97))


<a name="v2.4.0"></a>
## [v2.4.0] - 2021-06-11

- feat: ALB/NLB log delivery support ([#96](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/96))


<a name="v2.3.0"></a>
## [v2.3.0] - 2021-06-07



<a name="v2.2.0"></a>
## [v2.2.0] - 2021-05-15

- feat: Add module wrappers ([#92](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/92))
- chore: update CI/CD to use stable `terraform-docs` release artifact and discoverable Apache2.0 license ([#91](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/91))


<a name="v2.1.0"></a>
## [v2.1.0] - 2021-04-28

- feat: support bucket_key_enabled for SSE ([#82](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/82))
- chore: Updated versions in README


<a name="v2.0.0"></a>
## [v2.0.0] - 2021-04-26

- feat: Shorten outputs (removing this_) ([#88](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/88))


<a name="v1.25.0"></a>
## [v1.25.0] - 2021-04-10

- fix: Bump minimum provider version to 3.28 ([#81](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/81))


<a name="v1.24.0"></a>
## [v1.24.0] - 2021-04-09

- feat: Added workaround for variable type `any` ([#79](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/79))


<a name="v1.23.0"></a>
## [v1.23.0] - 2021-04-09

- feat: Add ability to create deny insecure transport policy ([#77](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/77))
- chore: update documentation and pin `terraform_docs` version to avoid future changes ([#76](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/76))


<a name="v1.22.0"></a>
## [v1.22.0] - 2021-03-22

- fix: ACL value can be null even when using Terragrunt ([#75](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/75))


<a name="v1.21.0"></a>
## [v1.21.0] - 2021-03-17

- feat: Added modules/object (Happy Amazon S3 Pi Day!) ([#74](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/74))
- chore: align ci-cd static checks to use individual minimum Terraform versions ([#73](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/73))


<a name="v1.20.0"></a>
## [v1.20.0] - 2021-03-01

- fix: Update syntax for Terraform 0.15 ([#71](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/71))
- fix: Updated example to prevent from accidental object locking


<a name="v1.19.0"></a>
## [v1.19.0] - 2021-03-01

- chore: add ci-cd workflow for pre-commit checks ([#68](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/68))


<a name="v1.18.0"></a>
## [v1.18.0] - 2021-02-20

- chore: update documentation based on latest `terraform-docs` which includes module and resource sections ([#66](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/66))


<a name="v1.17.0"></a>
## [v1.17.0] - 2020-12-09

- fix: Change ELB Log Delivery Policy to use ARN output to support Gov Cloud ([#60](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/60))


<a name="v1.16.0"></a>
## [v1.16.0] - 2020-10-30

- feat: Creating SNS/SQS policies should be optional ([#54](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/54))


<a name="v1.15.0"></a>
## [v1.15.0] - 2020-10-08

- fix: Fixed cors_rules variable type ([#49](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/49))


<a name="v1.14.0"></a>
## [v1.14.0] - 2020-10-08

- fix: Fixed grant variable type ([#46](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/46))


<a name="v1.13.0"></a>
## [v1.13.0] - 2020-10-06

- feat: Add bucket acl policy grants ([#44](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/44))
- Updated docs


<a name="v1.12.0"></a>
## [v1.12.0] - 2020-08-17

- fix: Using required arguments instead of lookup in replication_configuration ([#35](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/35))


<a name="v1.11.0"></a>
## [v1.11.0] - 2020-08-17

- feat: support a list of CORS rules instead of a single rule ([#40](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/40))


<a name="v1.10.0"></a>
## [v1.10.0] - 2020-08-13

- feat: Remove region parameter for 3.0 aws provider ([#38](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/38))


<a name="v1.9.0"></a>
## [v1.9.0] - 2020-07-01

- chore: Allow Terraform 0.13 ([#36](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/36))


<a name="v1.8.0"></a>
## [v1.8.0] - 2020-06-12

- feat: Added attach_public_policy as conditional switch ([#34](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/34))
- feat: Updated variable name in notification module


<a name="v1.7.0"></a>
## [v1.7.0] - 2020-05-24

- feat: Added modules/notifications for S3 bucket notifications ([#31](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/31))
- docs: Fix link for complete S3 example to replication S3 example ([#19](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/19))


<a name="v1.6.0"></a>
## [v1.6.0] - 2020-03-06

- Added AWS S3 bucket public access block ([#18](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/18))


<a name="v1.5.0"></a>
## [v1.5.0] - 2020-01-07

- Fix kms_master_key_id to conform with terraform resource ([#5](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/5))


<a name="v1.4.0"></a>
## [v1.4.0] - 2019-11-22

- Fix for bucket policy count when value is not computed ([#12](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/12))


<a name="v1.3.0"></a>
## [v1.3.0] - 2019-11-22

- Updated example to show bucket policy usage


<a name="v1.2.0"></a>
## [v1.2.0] - 2019-11-21

- Output bucket id from s3_bucket_policy to make sure that policy is present before it can be used


<a name="v1.1.0"></a>
## [v1.1.0] - 2019-11-20

- Added support for S3 bucket policy (incl. ELB logs delivery policy) ([#10](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/10))


<a name="v0.1.0"></a>
## [v0.1.0] - 2019-08-29



<a name="v1.0.0"></a>
## [v1.0.0] - 2019-08-29

- Rewrite to match other modules, added all existing S3 features


<a name="v0.0.1"></a>
## v0.0.1 - 2019-07-21

- Minor formatting, cleanups, readme
- Initial release of this module ([#4](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/4))
- Initial commit


[Unreleased]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v2.11.0...HEAD
[v2.11.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v2.10.0...v2.11.0
[v2.10.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v2.9.0...v2.10.0
[v2.9.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v2.8.0...v2.9.0
[v2.8.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v2.7.0...v2.8.0
[v2.7.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v2.6.0...v2.7.0
[v2.6.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v2.5.0...v2.6.0
[v2.5.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v2.4.0...v2.5.0
[v2.4.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v2.3.0...v2.4.0
[v2.3.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v2.2.0...v2.3.0
[v2.2.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v2.1.0...v2.2.0
[v2.1.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v2.0.0...v2.1.0
[v2.0.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v1.25.0...v2.0.0
[v1.25.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v1.24.0...v1.25.0
[v1.24.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v1.23.0...v1.24.0
[v1.23.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v1.22.0...v1.23.0
[v1.22.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v1.21.0...v1.22.0
[v1.21.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v1.20.0...v1.21.0
[v1.20.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v1.19.0...v1.20.0
[v1.19.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v1.18.0...v1.19.0
[v1.18.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v1.17.0...v1.18.0
[v1.17.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v1.16.0...v1.17.0
[v1.16.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v1.15.0...v1.16.0
[v1.15.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v1.14.0...v1.15.0
[v1.14.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v1.13.0...v1.14.0
[v1.13.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v1.12.0...v1.13.0
[v1.12.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v1.11.0...v1.12.0
[v1.11.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v1.10.0...v1.11.0
[v1.10.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v1.9.0...v1.10.0
[v1.9.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v1.8.0...v1.9.0
[v1.8.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v1.7.0...v1.8.0
[v1.7.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v1.6.0...v1.7.0
[v1.6.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v1.5.0...v1.6.0
[v1.5.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v1.4.0...v1.5.0
[v1.4.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v1.3.0...v1.4.0
[v1.3.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v1.2.0...v1.3.0
[v1.2.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v1.1.0...v1.2.0
[v1.1.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v0.1.0...v1.1.0
[v0.1.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v1.0.0...v0.1.0
[v1.0.0]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v0.0.1...v1.0.0
