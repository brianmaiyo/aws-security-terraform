# Deployment status and regional capabilities
output "deployment_summary" {
  description = "Summary of deployed services and regional capabilities"
  value = local.deployment_summary
}

output "regional_capabilities" {
  description = "Current region's service capabilities"
  value = local.current_region_capabilities
}

output "guardduty_features" {
  description = "GuardDuty features enabled in this deployment"
  value = local.guardduty_features
}

output "inspector_services" {
  description = "Inspector services enabled in this deployment"  
  value = local.inspector_services
}

output "security_services_status" {
  description = "Status of all security services"
  value = {
    guardduty = {
      detector_id = aws_guardduty_detector.main.id
      s3_bucket = aws_s3_bucket.guardduty_findings.bucket
      kms_key = aws_kms_key.guardduty.arn
    }
    security_hub = {
      enabled = var.enable_security_hub
      account_id = var.enable_security_hub ? aws_securityhub_account.main[0].id : null
      standards_disabled_reason = "ARN format issues in current region"
    }
    inspector = {
      ec2_enabled = local.inspector_services.enable_ec2
      ecr_enabled = local.inspector_services.enable_ecr  
      lambda_enabled = local.inspector_services.enable_lambda
      disabled_reason = local.deployment_summary.regional_limitations.has_inspector_timeouts ? "Timeout issues in EU regions" : null
    }
  }
}