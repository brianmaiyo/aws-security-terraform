# AWS Security Services Terraform Configuration

Simple Terraform configuration that sets up AWS security monitoring with GuardDuty, Security Hub, and Inspector.

## What This Deploys

- **GuardDuty**: Threat detection for your AWS account with all protection features enabled
- **Security Hub**: Central security dashboard with AWS Foundational and CIS standards
- **Inspector**: Vulnerability scanning for EC2, ECR, and Lambda (Lambda disabled in EU regions)
- **S3 Bucket**: Encrypted storage for GuardDuty findings with lifecycle management
- **KMS Key**: Dedicated encryption key for GuardDuty findings

## Prerequisites

1. AWS CLI configured with admin permissions
2. Terraform >= 1.0 installed

## Quick Start

1. **Configure**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars - change the S3 bucket name to be globally unique
   ```

2. **Deploy**
   ```bash
   terraform init
   terraform apply
   ```

That's it! Your AWS security monitoring is now active.

## Configuration Options

### Configuration

Only 4 variables to configure:

```hcl
aws_region   = "us-east-1"                              # Your AWS region
project_name = "my-company-security"                    # For resource naming
guardduty_findings_s3_bucket_name = "my-unique-bucket" # Must be globally unique
enable_security_hub = true                             # Enable Security Hub
```

## Regional Notes

- **EU Regions**: Inspector Lambda scanning is automatically disabled due to timeout issues
- **All Regions**: GuardDuty and Security Hub work everywhere
- **S3 Bucket**: Must have a globally unique name

## What Gets Created

- GuardDuty detector with all protection features enabled
- S3 bucket for findings (encrypted with KMS)
- KMS key for encryption
- Security Hub with AWS Foundational and CIS standards
- Inspector scanning for EC2, ECR, and Lambda (where supported)
- All necessary IAM roles (created automatically by AWS)

## Troubleshooting

**S3 Bucket Already Exists**: Change the bucket name in `terraform.tfvars` to something globally unique.

**Permission Errors**: Make sure your AWS credentials have admin permissions.

**EU Regions**: Inspector Lambda scanning is automatically disabled - this is normal.

## Verification

After deployment, check the AWS console:
- GuardDuty: Should show enabled detector
- Security Hub: Should show enabled standards  
- Inspector: Should show enabled scanning

## Cleanup

```bash
terraform destroy
```

This will remove all security services and the S3 bucket with findings.