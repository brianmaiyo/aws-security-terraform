# Local values for comprehensive regional configurations
locals {
  # Current region information
  current_region = data.aws_region.current.name
  current_account = data.aws_caller_identity.current.account_id
  current_partition = data.aws_partition.current.partition

  # Comprehensive regional service support matrix
  regional_services = {
    # US Regions - Full support
    "us-east-1" = {
      guardduty_malware_protection = true
      inspector_ec2               = true
      inspector_ecr               = true
      inspector_lambda            = true
      security_hub_standards      = true
      security_hub_cis_v140       = true
      security_hub_aws_foundational = true
    }
    "us-east-2" = {
      guardduty_malware_protection = true
      inspector_ec2               = true
      inspector_ecr               = true
      inspector_lambda            = true
      security_hub_standards      = true
      security_hub_cis_v140       = true
      security_hub_aws_foundational = true
    }
    "us-west-1" = {
      guardduty_malware_protection = true
      inspector_ec2               = true
      inspector_ecr               = true
      inspector_lambda            = true
      security_hub_standards      = true
      security_hub_cis_v140       = true
      security_hub_aws_foundational = true
    }
    "us-west-2" = {
      guardduty_malware_protection = true
      inspector_ec2               = true
      inspector_ecr               = true
      inspector_lambda            = true
      security_hub_standards      = true
      security_hub_cis_v140       = true
      security_hub_aws_foundational = true
    }
    
    # EU Regions - Limited support due to service issues
    "eu-west-1" = {
      guardduty_malware_protection = false  # IAM permission issues
      inspector_ec2               = false   # Timeout issues
      inspector_ecr               = false   # Timeout issues
      inspector_lambda            = false   # Not supported
      security_hub_standards      = false   # ARN format issues
      security_hub_cis_v140       = false   # ARN format issues
      security_hub_aws_foundational = false # ARN format issues
    }
    "eu-west-2" = {
      guardduty_malware_protection = false
      inspector_ec2               = false
      inspector_ecr               = false
      inspector_lambda            = false
      security_hub_standards      = false
      security_hub_cis_v140       = false
      security_hub_aws_foundational = false
    }
    "eu-central-1" = {
      guardduty_malware_protection = false
      inspector_ec2               = false
      inspector_ecr               = false
      inspector_lambda            = false
      security_hub_standards      = false
      security_hub_cis_v140       = false
      security_hub_aws_foundational = false
    }
    
    # Asia Pacific Regions - Partial support
    "ap-southeast-1" = {
      guardduty_malware_protection = true
      inspector_ec2               = true
      inspector_ecr               = true
      inspector_lambda            = false  # Limited support
      security_hub_standards      = true
      security_hub_cis_v140       = true
      security_hub_aws_foundational = true
    }
    "ap-southeast-2" = {
      guardduty_malware_protection = true
      inspector_ec2               = true
      inspector_ecr               = true
      inspector_lambda            = false
      security_hub_standards      = true
      security_hub_cis_v140       = true
      security_hub_aws_foundational = true
    }
    
    # Africa Regions - Testing full support (can be adjusted based on results)
    "af-south-1" = {
      guardduty_malware_protection = true   # TESTING: Enable to see if IAM issues exist
      inspector_ec2               = true    # TESTING: Enable to see if timeout issues exist
      inspector_ecr               = true    # TESTING: Enable to see if timeout issues exist
      inspector_lambda            = false   # Keep disabled - limited support in newer regions
      security_hub_standards      = true    # TESTING: Enable to see if ARN format works
      security_hub_cis_v140       = true    # TESTING: Enable to see if ARN format works
      security_hub_aws_foundational = true  # TESTING: Enable to see if ARN format works
    }
    
    # Middle East Regions - Conservative support (newer regions)
    "me-south-1" = {
      guardduty_malware_protection = false
      inspector_ec2               = false
      inspector_ecr               = false
      inspector_lambda            = false
      security_hub_standards      = false
      security_hub_cis_v140       = false
      security_hub_aws_foundational = false
    }
  }

  # Get current region capabilities (with fallback for unsupported regions)
  current_region_capabilities = lookup(local.regional_services, local.current_region, {
    guardduty_malware_protection = false
    inspector_ec2               = false
    inspector_ecr               = false
    inspector_lambda            = false
    security_hub_standards      = false
    security_hub_cis_v140       = false
    security_hub_aws_foundational = false
  })

  # Security Hub standards ARNs - Enable for testing in supported regions
  security_hub_standards_enabled = local.current_region_capabilities.security_hub_standards
  
  # Alternative: Just enable Security Hub account without standards for problematic regions
  security_hub_account_only = !local.current_region_capabilities.security_hub_standards

  # GuardDuty feature support
  guardduty_features = {
    enable_s3_logs              = true  # Available in all regions
    enable_kubernetes_logs      = true  # Available in all regions
    enable_malware_protection   = local.current_region_capabilities.guardduty_malware_protection
    enable_rds_login_events     = true  # Available in all regions
    enable_lambda_network_logs  = true  # Available in all regions
    enable_eks_runtime_monitoring = true # Available in all regions
    enable_runtime_monitoring   = true  # Available in all regions
  }

  # Inspector service enablement
  inspector_services = {
    enable_ec2    = var.enable_inspector && local.current_region_capabilities.inspector_ec2
    enable_ecr    = var.enable_inspector && local.current_region_capabilities.inspector_ecr
    enable_lambda = var.enable_inspector && var.enable_inspector_lambda && local.current_region_capabilities.inspector_lambda
  }

  # Deployment summary for outputs
  deployment_summary = {
    region = local.current_region
    account = local.current_account
    services_enabled = {
      guardduty = true
      guardduty_malware_protection = local.guardduty_features.enable_malware_protection
      inspector_ec2 = local.inspector_services.enable_ec2
      inspector_ecr = local.inspector_services.enable_ecr
      inspector_lambda = local.inspector_services.enable_lambda
      security_hub = var.enable_security_hub
      security_hub_standards = local.security_hub_standards_enabled
    }
    regional_limitations = {
      has_inspector_timeouts = contains(["eu-west-1", "eu-west-2", "eu-central-1", "af-south-1", "me-south-1"], local.current_region)
      has_security_hub_arn_issues = contains(["eu-west-1", "eu-west-2", "eu-central-1", "af-south-1", "me-south-1"], local.current_region)
      has_guardduty_iam_issues = contains(["eu-west-1", "eu-west-2", "eu-central-1", "af-south-1", "me-south-1"], local.current_region)
      is_newer_region = contains(["af-south-1", "me-south-1"], local.current_region)
    }
  }
}