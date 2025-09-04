# 🛡️ AWS Security Services Terraform Configuration

[![Terraform](https://img.shields.io/badge/Terraform-1.0+-623CE4?logo=terraform&logoColor=white)](https://terraform.io)
[![AWS](https://img.shields.io/badge/AWS-Security%20Services-FF9900?logo=amazon-aws&logoColor=white)](https://aws.amazon.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Enterprise-grade AWS security monitoring in 5 minutes. This Terraform configuration automatically deploys and configures AWS GuardDuty, Security Hub, and Inspector with intelligent regional compatibility handling.

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

## ✨ What This Deploys

| Service | Features | Regional Support |
|---------|----------|------------------|
| **🔍 GuardDuty** | Threat detection, malware protection, runtime monitoring | ✅ All regions |
| **🎯 Security Hub** | Central dashboard, AWS Foundational + CIS standards | ✅ All regions |
| **🔬 Inspector** | EC2, ECR, Lambda vulnerability scanning | ⚠️ Lambda disabled in EU |
| **🗄️ S3 Bucket** | Encrypted findings storage with lifecycle management | ✅ All regions |
| **🔐 KMS Key** | Dedicated encryption key with automatic rotation | ✅ All regions |

## 🚀 Quick Start

### Prerequisites

- ✅ **AWS Account** with admin permissions
- ✅ **Terraform** >= 1.0 installed
- ✅ **AWS CLI** configured with credentials

### 1. Configure

```bash
# Clone or download this repository
git clone <repository-url>
cd aws-security-terraform

# Copy and edit configuration
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your settings:

```hcl
aws_region   = "us-east-1"                              # Your AWS region
project_name = "my-company-security"                    # For resource naming
guardduty_findings_s3_bucket_name = "my-unique-bucket" # Must be globally unique
enable_security_hub = true                             # Enable Security Hub
```

> **⚠️ Important**: The S3 bucket name must be globally unique across all AWS accounts worldwide.

### 2. Deploy

```bash
terraform init
terraform apply
```

Type `yes` when prompted. Deployment takes 2-5 minutes.

### 3. Verify

Check the AWS Console:

| Service | Verification Steps |
|---------|-------------------|
| **GuardDuty** | Console → GuardDuty → Should show "Enabled" with all protections |
| **Security Hub** | Console → Security Hub → Should show enabled standards |
| **Inspector** | Console → Inspector → Should show enabled scanning |

## 🌍 Regional Compatibility

This configuration includes intelligent regional compatibility handling:

### ✅ Fully Supported Regions
- **US Regions**: All features work perfectly
- **Asia Pacific**: All features supported
- **Canada/South America**: All features supported

### ⚠️ EU Regions (Special Handling)
- **GuardDuty**: ✅ Full functionality
- **Security Hub**: ✅ Full functionality  
- **Inspector EC2/ECR**: ✅ Enabled
- **Inspector Lambda**: ❌ Automatically disabled (AWS timeout issues)

### 🔧 Automatic Regional Detection

The configuration automatically detects your region and adjusts services accordingly:

```hcl
# Example: Lambda scanning disabled in EU regions
count = contains(["eu-west-1", "eu-west-2", "eu-central-1"], data.aws_region.current.name) ? 0 : 1
```

## 📁 Project Structure

```
├── 📄 main.tf              # Provider and data sources
├── 📄 variables.tf         # Configuration variables
├── 📄 data.tf             # AWS environment detection
├── 📄 locals.tf           # Regional capability matrix
├── 🛡️ guardduty.tf        # GuardDuty configuration
├── 🔬 inspector.tf        # Inspector configuration  
├── 🎯 security_hub.tf     # Security Hub configuration
├── 📊 outputs.tf          # Deployment status outputs
├── ⚙️ terraform.tfvars    # Your configuration
└── 📚 terraform.tfvars.example # Example configuration
```

## 🔧 Implementation Details

### GuardDuty Features Enabled

- **🌐 S3 Protection**: Monitors S3 API calls for threats
- **☸️ EKS Protection**: Kubernetes audit log analysis
- **🦠 Malware Protection**: EBS volume scanning (where supported)
- **🗄️ RDS Protection**: Database login monitoring
- **⚡ Lambda Protection**: Serverless function monitoring
- **🏃 Runtime Monitoring**: EC2 and EKS runtime analysis

### Security Hub Standards

- **📋 AWS Foundational Security Best Practices v1.0.0**
- **🏛️ CIS AWS Foundations Benchmark v1.4.0**
- **🔗 Automatic Integration** with GuardDuty and Inspector

### Inspector Scanning

- **💻 EC2 Instances**: Operating system and application vulnerabilities
- **📦 ECR Images**: Container image vulnerability scanning
- **⚡ Lambda Functions**: Serverless application vulnerabilities (non-EU regions)

## 🔐 Security Features

### Encryption & Access Control
- **🔐 KMS Encryption**: Dedicated key with automatic rotation
- **🔒 S3 Security**: HTTPS-only, account-isolated access
- **🛡️ IAM Integration**: Service-linked roles created automatically

### Lifecycle Management
- **📅 30 days**: Transition to Infrequent Access storage
- **🧊 90 days**: Transition to Glacier storage
- **🗑️ 365 days**: Automatic deletion (configurable)

## 💰 Cost Estimation

Typical monthly costs for small-medium environments:

| Service | Estimated Cost |
|---------|----------------|
| GuardDuty | $15-50 |
| Security Hub | $5-15 |
| Inspector | $5-20 |
| S3 Storage | $1-5 |
| **Total** | **$26-90/month** |

> Costs vary based on resource count and findings volume.

## 🔍 Monitoring & Outputs

After deployment, Terraform outputs comprehensive status information:

```hcl
# Example output
deployment_summary = {
  account = "123456789012"
  region = "us-east-1"
  services_enabled = {
    guardduty = true
    security_hub = true
    inspector_ec2 = true
    inspector_ecr = true
    inspector_lambda = true
  }
}
```

## 🛠️ Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| **"Bucket already exists"** | Change bucket name in `terraform.tfvars` to something globally unique |
| **"Access denied"** | Ensure AWS credentials have admin permissions |
| **"Service not available"** | Check if region supports the service (handled automatically) |
| **"InvalidClientTokenId"** | Check AWS credentials and region access permissions |

### Regional Access Issues

If you encounter credential errors in specific regions:

1. **Check region opt-in status**:
   ```bash
   aws ec2 describe-regions --region-names <region-name>
   ```

2. **Verify IAM permissions** for the target region

3. **Use a supported region** like `us-east-1` or `eu-west-1`

## 🧪 Testing & Validation

### Automated Testing
The configuration includes comprehensive regional capability detection and automatic service enablement based on regional support.

### Manual Verification Steps

1. **GuardDuty**: Check detector status and protection features
2. **Security Hub**: Verify standards subscriptions and integrations
3. **Inspector**: Confirm scanning is active for supported resource types
4. **S3 Bucket**: Verify encryption and lifecycle policies
5. **Findings Flow**: Wait 15-30 minutes for initial findings

## 🔄 Maintenance

### Updates
- **Terraform State**: Keep `terraform.tfstate` secure and backed up
- **Provider Updates**: Regularly update AWS provider version
- **Standards**: Security Hub standards are automatically updated by AWS

### Monitoring
- **CloudWatch**: Monitor service health and costs
- **Security Hub**: Review findings and compliance scores regularly
- **S3 Costs**: Monitor findings storage costs

## 🧹 Cleanup

To remove all resources:

```bash
terraform destroy
```

This will:
- Disable all security services
- Delete the S3 bucket and all findings
- Remove the KMS key (after 7-day waiting period)
- Clean up all associated resources

## 📚 Additional Resources

- **AWS Documentation**: [AWS Security Services](https://docs.aws.amazon.com/security/)
- **Terraform AWS Provider**: [Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- **GuardDuty User Guide**: [AWS GuardDuty](https://docs.aws.amazon.com/guardduty/)
- **Security Hub User Guide**: [AWS Security Hub](https://docs.aws.amazon.com/securityhub/)
- **Inspector User Guide**: [AWS Inspector](https://docs.aws.amazon.com/inspector/)

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**🎯 Ready to secure your AWS environment?** Just run `terraform apply` and you'll have enterprise-grade security monitoring in minutes!