package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Test the Terraform module in examples/complete using Terratest.
func TestS3Replication(t *testing.T) {
	t.Parallel()

	// Expect Values
	expectedNameOrigin := fmt.Sprintf("origin-s3-bucket%s", strings.ToLower(random.UniqueId()))
	expectedNameReplica := fmt.Sprintf("replica-s3-bucket-%s", strings.ToLower(random.UniqueId()))
	awsRegionOrigin := aws.GetRandomStableRegion(t, nil, nil)
	awsRegionReplica := aws.GetRandomStableRegion(t, nil, nil)

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../examples/s3-replication",
		Upgrade:      true,

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"origin_bucket_name":  expectedNameOrigin,
			"replica_bucket_name": expectedNameReplica,
			"origin_region":       awsRegionOrigin,
			"replica_region":      awsRegionReplica,
		},
	}
	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	thisS3BucketID := terraform.Output(t, terraformOptions, "this_s3_bucket_id")
	assert.Equal(t, expectedNameOrigin, thisS3BucketID)

	thisReplicaBucketID := terraform.Output(t, terraformOptions, "this_replica_s3_bucket_id")
	assert.Equal(t, expectedNameReplica, thisReplicaBucketID)

	thisS3BucketRegionOrigin := terraform.Output(t, terraformOptions, "this_s3_bucket_region")
	assert.Equal(t, awsRegionOrigin, thisS3BucketRegionOrigin)

	thisS3BucketRegionReplica := terraform.Output(t, terraformOptions, "this_s3_bucket_replica_region")
	assert.Equal(t, awsRegionReplica, thisS3BucketRegionReplica)
}
