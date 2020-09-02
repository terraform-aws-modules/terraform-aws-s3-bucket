# Change Log

All notable changes to this project will be documented in this file.

<a name="unreleased"></a>
## [Unreleased]



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


[Unreleased]: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/compare/v1.12.0...HEAD
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
