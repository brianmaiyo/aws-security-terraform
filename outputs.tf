# GuardDuty Outputs
output "guardduty_detector_id" {
  description = "The ID of the GuardDuty detector"
  value       = aws_guardduty_detector.main.id
}

output "guardduty_kms_key_id" {
  description = "The ID of the GuardDuty KMS key"
  value       = aws_kms_key.guardduty.key_id
}

output "guardduty_kms_key_arn" {
  description = "The ARN of the GuardDuty KMS key"
  value       = aws_kms_key.guardduty.arn
}

output "guardduty_s3_bucket_name" {
  description = "The name of the S3 bucket for GuardDuty findings"
  value       = aws_s3_bucket.guardduty_findings.bucket
}

output "guardduty_s3_bucket_arn" {
  description = "The ARN of the S3 bucket for GuardDuty findings"
  value       = aws_s3_bucket.guardduty_findings.arn
}

# Security Hub Outputs
output "security_hub_account_id" {
  description = "The AWS account ID associated with Security Hub"
  value       = aws_securityhub_account.main.id
}

# Security Hub standards are commented out due to region-specific ARN issues
# output "security_hub_standards" {
#   description = "List of enabled Security Hub standards"
#   value = {
#     aws_foundational = aws_securityhub_standards_subscription.aws_foundational.standards_arn
#     nist_800_53      = aws_securityhub_standards_subscription.nist_800_53.standards_arn
#     cis_foundations  = aws_securityhub_standards_subscription.cis_aws_foundations.standards_arn
#   }
# }

# Inspector Outputs
output "inspector_enablers" {
  description = "Inspector enabler resource types"
  value = {
    ec2 = aws_inspector2_enabler.ec2.resource_types
    # ecr and lambda enablers commented out due to timeout issues
    # ecr    = aws_inspector2_enabler.ecr.resource_types
    # lambda = aws_inspector2_enabler.lambda.resource_types
  }
}