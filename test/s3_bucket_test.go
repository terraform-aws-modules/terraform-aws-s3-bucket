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
func TestS3Simple(t *testing.T) {
	t.Parallel()

	// Expect Values
	expectedName := fmt.Sprintf("origin-%s", strings.ToLower(random.UniqueId()))
	awsRegion := aws.GetRandomStableRegion(t, nil, nil)

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../examples/s3-simple",
		Upgrade:      true,

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"bucket_name": expectedName,
			"region":      awsRegion,
		},
	}
	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	thisS3BucketID := terraform.Output(t, terraformOptions, "this_s3_bucket_id")
	assert.Equal(t, expectedName, thisS3BucketID)

	thisS3BucketRegion := terraform.Output(t, terraformOptions, "this_s3_bucket_region")
	assert.Equal(t, awsRegion, thisS3BucketRegion)
}
