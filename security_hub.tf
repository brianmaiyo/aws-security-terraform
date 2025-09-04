resource "aws_securityhub_account" "main" {
  count = var.enable_security_hub ? 1 : 0

  enable_default_standards = false
}

# Security Hub standards - enabled for testing in supported regions

# AWS Foundational Security Best Practices
resource "aws_securityhub_standards_subscription" "aws_foundational" {
  count = var.enable_security_hub && local.current_region_capabilities.security_hub_aws_foundational ? 1 : 0
  
  standards_arn = "arn:${data.aws_partition.current.partition}:securityhub:${data.aws_region.current.name}::standard/aws-foundational-security-best-practices/v/1.0.0"
  depends_on    = [aws_securityhub_account.main]

  lifecycle {
    ignore_changes = [
      # Ignore version changes to prevent unnecessary updates
      standards_arn
    ]
  }
}

# CIS AWS Foundations Benchmark
resource "aws_securityhub_standards_subscription" "cis_benchmark" {
  count = var.enable_security_hub && local.current_region_capabilities.security_hub_cis_v140 ? 1 : 0
  
  standards_arn = "arn:${data.aws_partition.current.partition}:securityhub:${data.aws_region.current.name}::standard/cis-aws-foundations-benchmark/v/1.4.0"
  depends_on    = [aws_securityhub_account.main]

  lifecycle {
    ignore_changes = [
      # Ignore version changes to prevent unnecessary updates
      standards_arn
    ]
  }
}

# GuardDuty integration
resource "aws_securityhub_product_subscription" "guardduty" {
  count = var.enable_security_hub ? 1 : 0

  product_arn = "arn:${data.aws_partition.current.partition}:securityhub:${data.aws_region.current.name}::product/aws/guardduty"
  depends_on  = [aws_securityhub_account.main]
}

# Inspector integration
resource "aws_securityhub_product_subscription" "inspector" {
  count = var.enable_security_hub ? 1 : 0

  product_arn = "arn:${data.aws_partition.current.partition}:securityhub:${data.aws_region.current.name}::product/aws/inspector"
  depends_on  = [aws_securityhub_account.main]
}