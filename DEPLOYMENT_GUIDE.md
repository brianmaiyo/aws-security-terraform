# AWS Security Services Deployment Guide

Simple guide to deploy AWS security monitoring in 5 minutes.

## What You'll Get

- **GuardDuty**: Threat detection for your entire AWS account
- **Security Hub**: Central security dashboard with compliance standards
- **Inspector**: Vulnerability scanning for your resources
- **Encrypted Storage**: Secure S3 bucket for all security findings

## Prerequisites

1. **AWS Account** with admin permissions
2. **Terraform** installed (version 1.0+)
3. **AWS CLI** configured with your credentials

## Step 1: Get the Code

Download or clone this repository to your computer.

## Step 2: Configure

Copy the example configuration:
```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your settings:
```hcl
aws_region   = "us-east-1"                              # Your AWS region
project_name = "my-company-security"                    # For resource naming  
guardduty_findings_s3_bucket_name = "my-unique-bucket" # Must be globally unique
enable_security_hub = true                             # Enable Security Hub
```

**Important**: The S3 bucket name must be globally unique across all AWS accounts worldwide.

## Step 3: Deploy

```bash
terraform init
terraform apply
```

Type `yes` when prompted. Deployment takes 2-5 minutes.

## Step 4: Verify

Check the AWS Console:

**GuardDuty**: Go to GuardDuty console → should show "Enabled" with all protections active

**Security Hub**: Go to Security Hub console → should show enabled standards and integrations

**Inspector**: Go to Inspector console → should show enabled scanning for EC2, ECR, and Lambda

## Regional Notes

- **US Regions**: All features work perfectly
- **EU Regions**: Inspector Lambda scanning is automatically disabled (known AWS timeout issue)
- **Other Regions**: All features should work

## What Happens Next

- **GuardDuty** starts monitoring immediately
- **Inspector** begins scanning your resources  
- **Security findings** appear in Security Hub within 15-30 minutes
- **Findings** are stored encrypted in your S3 bucket

## Cost

Typical monthly costs for small environments:
- GuardDuty: $15-50
- Security Hub: $5-15  
- Inspector: $5-20
- S3 Storage: $1-5

## Cleanup

To remove everything:
```bash
terraform destroy
```

## Troubleshooting

**"Bucket already exists"**: Change the bucket name in `terraform.tfvars` to something unique.

**"Access denied"**: Make sure your AWS credentials have admin permissions.

**"Service not available"**: Some regions may not support all services - this is handled automatically.

## Support

- AWS Documentation: [AWS Security Services](https://docs.aws.amazon.com/security/)
- Terraform Documentation: [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

That's it! You now have enterprise-grade AWS security monitoring running.