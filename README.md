# AWS Security Services Terraform Configuration

This Terraform configuration sets up comprehensive AWS security services including GuardDuty, Security Hub, and Inspector with all the specified requirements.

## Features

### Amazon GuardDuty
- ✅ Enable and Configure GuardDuty
- ✅ Export Findings to S3 Bucket with KMS Key
- ✅ GuardDuty KMS Key with proper policies
- ✅ S3 Bucket with GuardDuty-specific bucket policy
- ✅ S3 Protection
- ✅ EKS Protection
- ✅ Runtime Monitoring (EKS, Fargate, EC2)
- ✅ Malware Protection for EC2 (with snapshot retention)
- ✅ RDS Protection
- ✅ Lambda Protection

### AWS Security Hub
- ✅ Enable Security Hub
- ✅ AWS Foundational Security Best Practices v1.0.0
- ✅ NIST Special Publication 800-53 Revision 5
- ✅ CIS AWS Foundations Benchmark v1.4.0
- ✅ GuardDuty integration
- ✅ Inspector integration

### Amazon Inspector
- ✅ Enable Inspector V2
- ✅ Amazon EC2 scanning (Hybrid mode)
- ✅ Amazon ECR scanning
- ✅ AWS Lambda scanning

## Prerequisites

1. AWS CLI configured with appropriate permissions
2. Terraform >= 1.0 installed
3. Appropriate IAM permissions for:
   - GuardDuty management
   - Security Hub management
   - Inspector management
   - S3 bucket creation and management
   - KMS key creation and management

## Required IAM Permissions

Your AWS credentials need the following permissions:
- `guardduty:*`
- `securityhub:*`
- `inspector2:*`
- `s3:*`
- `kms:*`
- `iam:GetRole`
- `iam:PassRole`

## Deployment Instructions

1. **Clone and Navigate**
   ```bash
   # Navigate to the terraform directory
   cd /path/to/terraform/files
   ```

2. **Configure Variables**
   ```bash
   # Copy the example variables file
   cp terraform.tfvars.example terraform.tfvars
   
   # Edit the variables to match your requirements
   # Especially update the S3 bucket name to be globally unique
   ```

3. **Initialize Terraform**
   ```bash
   terraform init
   ```

4. **Plan the Deployment**
   ```bash
   terraform plan
   ```

5. **Apply the Configuration**
   ```bash
   terraform apply
   ```

6. **Verify Deployment**
   - Check GuardDuty console for enabled detector and protections
   - Check Security Hub console for enabled standards
   - Check Inspector console for enabled scanning

## Configuration Options

### GuardDuty S3 Bucket Naming
- If `guardduty_findings_s3_bucket_name` is not specified, a random suffix will be added
- Ensure the bucket name is globally unique

### Protection Features
All GuardDuty protection features can be enabled/disabled via variables:
- `enable_guardduty_s3_protection`
- `enable_guardduty_eks_protection`
- `enable_guardduty_runtime_monitoring`
- `enable_guardduty_malware_protection`
- `enable_guardduty_rds_protection`
- `enable_guardduty_lambda_protection`

### Agent Management
- Set `enable_ec2_agent_management = true` to automatically manage GuardDuty agents on EC2 instances
- This enables automatic deployment and management of security agents for runtime monitoring and malware protection

### Malware Snapshot Retention
- Set `retain_malware_snapshots = true` to keep snapshots when malware is detected
- Set to `false` to automatically delete snapshots after scanning

## Important Notes

1. **Regional Deployment**: This configuration deploys services in a single region. For multi-region setup, deploy in each required region.

2. **Cost Considerations**: 
   - GuardDuty charges are based on data processed
   - Inspector charges are based on assessments run
   - Security Hub has a per-finding charge model

3. **Organizations**: If using AWS Organizations, consider enabling these services at the organization level for centralized management.

4. **Existing GuardDuty**: If GuardDuty is already enabled, you may need to import the existing detector:
   ```bash
   terraform import aws_guardduty_detector.main <detector-id>
   ```

## Troubleshooting

### Common Issues

1. **S3 Bucket Already Exists**: Ensure the bucket name is globally unique
2. **Insufficient Permissions**: Verify IAM permissions listed above
3. **Region Availability**: Ensure all services are available in your target region

### Validation Commands

```bash
# Check GuardDuty status
aws guardduty list-detectors

# Check Security Hub status
aws securityhub get-enabled-standards

# Check Inspector status
aws inspector2 batch-get-account-status
```

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

**Warning**: This will delete all security configurations and the S3 bucket with findings data.