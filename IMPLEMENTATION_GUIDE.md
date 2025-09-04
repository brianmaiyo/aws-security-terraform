# AWS Security Services Implementation Guide

This guide shows exactly how the simplified Terraform configuration implements AWS security services.

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│    GuardDuty    │    │  Security Hub   │    │   Inspector     │
│                 │    │                 │    │                 │
│ • Threat Detection │──▶│ • Central Dashboard │◀──│ • Vulnerability │
│ • All Protections  │    │ • AWS Foundational │    │   Scanning      │
│ • Findings to S3   │    │ • CIS Benchmark    │    │ • EC2/ECR/Lambda│
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                        │                        │
         └────────────────────────┼────────────────────────┘
                                  ▼
                    ┌─────────────────────────┐
                    │      S3 Bucket          │
                    │   (KMS Encrypted)       │
                    │  GuardDuty Findings     │
                    └─────────────────────────┘
```

## 📁 File Structure

```
├── main.tf              # Provider and data sources
├── variables.tf         # 4 simple variables
├── guardduty.tf        # GuardDuty configuration
├── inspector.tf        # Inspector configuration  
├── security_hub.tf     # Security Hub configuration
└── terraform.tfvars   # Your configuration
```

## 🔧 Implementation Details

### main.tf - Foundation
```hcl
terraform {
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.aws_region
}

# Data sources for account info
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}
```

**What this does**: Sets up Terraform and gets AWS account information.

### variables.tf - Configuration
```hcl
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "security-services"
}

variable "guardduty_findings_s3_bucket_name" {
  description = "S3 bucket name for GuardDuty findings (must be globally unique)"
  type        = string
  default     = null
}

variable "enable_security_hub" {
  description = "Enable AWS Security Hub"
  type        = bool
  default     = true
}
```

**What this does**: Defines the 4 essential configuration options.

### guardduty.tf - Threat Detection
Creates GuardDuty with all protection features enabled:

- **S3 Protection**: Monitors S3 API calls
- **EKS Protection**: Monitors Kubernetes audit logs  
- **Malware Protection**: Scans EBS volumes
- **RDS Protection**: Monitors database logins
- **Lambda Protection**: Monitors serverless functions
- **Runtime Monitoring**: Monitors EC2 and EKS runtime

Plus encrypted S3 bucket for findings storage with lifecycle management.

### inspector.tf - Vulnerability Scanning
```hcl
resource "aws_inspector2_enabler" "ec2" {
  account_ids    = [data.aws_caller_identity.current.account_id]
  resource_types = ["EC2"]
}

resource "aws_inspector2_enabler" "ecr" {
  account_ids    = [data.aws_caller_identity.current.account_id]
  resource_types = ["ECR"]
}

resource "aws_inspector2_enabler" "lambda" {
  count = contains(["eu-west-1", "eu-west-2", "eu-central-1"], data.aws_region.current.name) ? 0 : 1

  account_ids    = [data.aws_caller_identity.current.account_id]
  resource_types = ["LAMBDA"]
}
```

**What this does**: 
- Enables EC2 scanning (always)
- Enables ECR scanning (always)  
- Enables Lambda scanning (except EU regions due to timeout issues)

### security_hub.tf - Central Dashboard
```hcl
resource "aws_securityhub_account" "main" {
  count = var.enable_security_hub ? 1 : 0
  enable_default_standards = false
}

# AWS Foundational Security Best Practices
resource "aws_securityhub_standards_subscription" "aws_foundational" {
  count = var.enable_security_hub ? 1 : 0
  standards_arn = "arn:${data.aws_partition.current.partition}:securityhub:${data.aws_region.current.name}::standard/aws-foundational-security-best-practices/v/1.0.0"
  depends_on = [aws_securityhub_account.main]
}

# CIS AWS Foundations Benchmark
resource "aws_securityhub_standards_subscription" "cis_benchmark" {
  count = var.enable_security_hub ? 1 : 0
  standards_arn = "arn:${data.aws_partition.current.partition}:securityhub:${data.aws_region.current.name}::standard/cis-aws-foundations-benchmark/v/1.4.0"
  depends_on = [aws_securityhub_account.main]
}

# Integrations
resource "aws_securityhub_product_subscription" "guardduty" {
  count = var.enable_security_hub ? 1 : 0
  product_arn = "arn:${data.aws_partition.current.partition}:securityhub:${data.aws_region.current.name}::product/aws/guardduty"
  depends_on = [aws_securityhub_account.main]
}

resource "aws_securityhub_product_subscription" "inspector" {
  count = var.enable_security_hub ? 1 : 0
  product_arn = "arn:${data.aws_partition.current.partition}:securityhub:${data.aws_region.current.name}::product/aws/inspector"
  depends_on = [aws_securityhub_account.main]
}
```

**What this does**:
- Enables Security Hub
- Subscribes to AWS Foundational and CIS standards
- Integrates GuardDuty and Inspector findings

## 🔐 Security Features

### Encryption
- **KMS Key**: Dedicated key for GuardDuty findings
- **S3 Encryption**: All findings encrypted at rest
- **Key Rotation**: Automatic annual rotation enabled

### Access Control  
- **Bucket Policy**: Only GuardDuty can write to findings bucket
- **HTTPS Only**: All connections must use TLS
- **Account Isolation**: Findings isolated to your AWS account

### Lifecycle Management
- **30 days**: Transition to Infrequent Access storage
- **90 days**: Transition to Glacier storage  
- **365 days**: Delete findings (configurable)

## 🌍 Regional Behavior

### All Regions
- GuardDuty: Full functionality
- Security Hub: AWS Foundational + CIS standards
- Inspector: EC2 and ECR scanning

### EU Regions (eu-west-1, eu-west-2, eu-central-1)
- Inspector Lambda scanning: **Disabled** (timeout issues)
- All other features: **Enabled**

### Automatic Detection
The configuration automatically detects EU regions and disables Lambda scanning:
```hcl
count = contains(["eu-west-1", "eu-west-2", "eu-central-1"], data.aws_region.current.name) ? 0 : 1
```

## 🚀 Deployment Process

1. **Terraform Init**: Downloads AWS provider
2. **Resource Creation**: Creates resources in dependency order
3. **Service Integration**: Connects GuardDuty/Inspector to Security Hub
4. **Automatic Configuration**: AWS creates service-linked roles automatically

## ✅ Verification

After deployment, verify in AWS Console:

**GuardDuty Console**:
- Detector shows "Enabled" 
- All protection types show "Enabled"
- Findings start appearing within 15-30 minutes

**Security Hub Console**:
- Hub shows "Enabled"
- 2 standards subscribed (AWS Foundational + CIS)
- GuardDuty and Inspector integrations active

**Inspector Console**:
- Account status shows "Enabled"
- EC2, ECR scanning active
- Lambda scanning active (except EU regions)

## 🎯 Key Benefits

1. **Zero Configuration**: Works out of the box
2. **Regional Aware**: Handles EU Lambda issues automatically  
3. **Secure by Default**: Encryption, access controls, lifecycle management
4. **Cost Optimized**: Intelligent storage transitions
5. **Integrated**: All services feed into Security Hub dashboard

This implementation provides enterprise-grade AWS security monitoring with minimal complexity.