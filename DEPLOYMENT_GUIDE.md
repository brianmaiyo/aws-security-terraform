# AWS Security Services Deployment Guide - Complete Beginner's Guide

**Never used AWS or Terraform before? No problem!** This guide assumes you're starting from scratch and will walk you through every single step.

## What You'll Build (In Simple Terms)

Think of this as setting up a security system for your house, but for your cloud infrastructure. You'll install three main "security cameras":

1. **GuardDuty** = Your smart security guard that watches for suspicious activity
2. **Security Hub** = Your central security dashboard that shows everything in one place  
3. **Inspector** = Your vulnerability scanner that checks for weak spots

## What This Deployment Includes

This Terraform configuration sets up a complete AWS security monitoring stack:

### 🛡️ Amazon GuardDuty (Your Smart Security Guard)
**What it does**: Watches your AWS account 24/7 for bad guys trying to break in or do malicious things.

**What it protects**:
- **Your files in S3** (cloud storage buckets) - detects if someone's trying to steal your data
- **Your servers** (EC2 instances) - scans for malware and suspicious activity
- **Your databases** (RDS) - monitors who's logging in and when
- **Your containers** (EKS/Kubernetes) - watches for attacks on containerized apps
- **Your serverless functions** (Lambda) - monitors for suspicious code execution

**Think of it like**: A security guard with cameras everywhere, watching for break-ins, theft, or suspicious behavior.

### 🔍 AWS Security Hub (Your Security Dashboard)
**What it does**: Takes all the security alerts from different services and puts them in one easy-to-read dashboard.

**What you get**:
- **One place to see everything** - instead of checking 10 different places for security issues
- **Compliance reports** - tells you if you're following security best practices
- **Priority scoring** - shows you which problems to fix first
- **Automatic integration** - connects to GuardDuty and Inspector automatically

**Think of it like**: Your home security system's main panel that shows all alarms, cameras, and sensors in one place.

### 🔎 Amazon Inspector (Your Vulnerability Scanner)
**What it does**: Automatically scans your applications and infrastructure for security weaknesses.

**What it scans**:
- **Your servers** (EC2) - checks for outdated software with security holes
- **Your container images** (ECR) - scans Docker images for vulnerabilities before you use them
- **Your serverless functions** (Lambda) - checks your code for security issues

**Think of it like**: A security expert who regularly inspects your house for weak locks, broken windows, or other vulnerabilities that burglars could exploit.

## Before You Start (Prerequisites)

**Don't worry - we'll walk through each of these step by step!**

### 1. You Need an AWS Account
- **What**: An Amazon Web Services account (like signing up for Netflix, but for cloud computing)
- **Cost**: Free to create, but you'll pay for what you use (we'll cover costs later)
- **How to get one**: Go to [aws.amazon.com](https://aws.amazon.com) and click "Create AWS Account"
- **Important**: You'll need a credit card, but AWS has a free tier for new users

### 2. Basic Computer Requirements
- **Windows computer** (this guide is written for Windows)
- **Internet connection** 
- **Administrator access** on your computer (to install software)

## Step-by-Step Setup (Don't Skip This!)

### Step 1: Install AWS CLI (Your Connection to AWS)

**What is AWS CLI?** It's like a remote control for your AWS account that you use from your computer.

**Easy Installation Method:**
1. Go to [AWS CLI Download Page](https://aws.amazon.com/cli/)
2. Click "Download AWS CLI for Windows"
3. Run the downloaded file (AWS CLI installer)
4. Follow the installation wizard (just click "Next" through everything)

**Test if it worked:**
1. Open Command Prompt (press Windows key + R, type `cmd`, press Enter)
2. Type: `aws --version`
3. You should see something like: `aws-cli/2.x.x Python/3.x.x Windows/10`

**If it doesn't work:** Restart your computer and try the test again.

### Step 2: Install Terraform (Your Infrastructure Builder)

**What is Terraform?** Think of it as a blueprint system that builds your AWS infrastructure automatically.

**Easy Installation Method:**
1. Go to [terraform.io/downloads](https://www.terraform.io/downloads)
2. Download "Windows AMD64" (even if you have Intel - this works for both)
3. Extract the zip file to a folder like `C:\terraform`
4. Add Terraform to your PATH:
   - Press Windows key + R, type `sysdm.cpl`, press Enter
   - Click "Environment Variables"
   - Under "System Variables", find "Path" and click "Edit"
   - Click "New" and add `C:\terraform` (or wherever you put it)
   - Click OK on everything

**Test if it worked:**
1. Open a NEW Command Prompt window
2. Type: `terraform --version`
3. You should see: `Terraform v1.x.x`

**Easier Alternative - Use Chocolatey:**
If you have Chocolatey package manager installed:
```bash
choco install terraform
```

### Step 3: Get Your AWS Access Keys (Your Digital ID Card)

**What are Access Keys?** They're like a username and password that let Terraform access your AWS account.

**How to get them:**
1. Log into your AWS account at [console.aws.amazon.com](https://console.aws.amazon.com)
2. Click your name in the top-right corner
3. Click "Security credentials"
4. Scroll down to "Access keys"
5. Click "Create access key"
6. Choose "Command Line Interface (CLI)"
7. Check the box "I understand..." and click "Next"
8. Add a description like "Terraform deployment" and click "Create access key"
9. **IMPORTANT**: Copy both the Access Key ID and Secret Access Key - you can't see the secret again!

### Step 4: Configure AWS CLI (Connect Your Computer to AWS)

**Now let's connect everything:**
1. Open Command Prompt
2. Type: `aws configure`
3. When prompted, enter:
   - **AWS Access Key ID**: Paste the one you just copied
   - **AWS Secret Access Key**: Paste the secret you just copied
   - **Default region name**: Type `us-east-1` (or your preferred region)
   - **Default output format**: Type `json`

**Test if it worked:**
Type: `aws sts get-caller-identity`
You should see your account information in JSON format.

### Step 5: Set Up Permissions (Give Yourself Access)

**What are IAM permissions?** They're like keys that unlock different parts of AWS. You need the right keys to set up security services.

**The Easy Way (If you're the account owner):**
If you created the AWS account, you probably already have full permissions. Skip to the next section.

**The Proper Way (Recommended for security):**
1. In AWS Console, go to IAM (Identity and Access Management)
2. Click "Users" on the left
3. Click on your username
4. Click "Add permissions" → "Attach policies directly"
5. Search for and select these policies:
   - `AmazonGuardDutyFullAccess`
   - `AWSSecurityHubFullAccess`
   - `AmazonInspector2FullAccess`
   - `AmazonS3FullAccess`
   - `AWSKeyManagementServicePowerUser`

**For Advanced Users (Custom Policy):**
If you want minimal permissions, create a custom policy with these permissions:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "guardduty:*",
                "securityhub:*",
                "inspector2:*",
                "s3:*",
                "kms:*",
                "iam:GetRole",
                "iam:PassRole",
                "sts:GetCallerIdentity"
            ],
            "Resource": "*"
        }
    ]
}
```

## Now Let's Build Your Security System!

### Step 6: Download and Prepare the Configuration Files

**First, get the files:**
1. Download or clone this repository to your computer
2. Open Command Prompt and navigate to the folder with the Terraform files
   - Example: `cd C:\Users\YourName\Downloads\aws-security-terraform`

### Step 7: Customize Your Settings

**Copy the example settings file:**
```bash
copy terraform.tfvars.example terraform.tfvars
```

**Edit your settings:**
1. Open `terraform.tfvars` in Notepad (or any text editor)
2. Change these values to match your needs:

```hcl
# Basic Configuration - CHANGE THESE!
aws_region   = "us-east-1"                    # Your AWS region (us-east-1 is fine for most people)
environment  = "production"                    # Can be "production", "staging", "dev", etc.
project_name = "mycompany-security"           # Replace "mycompany" with your actual company name

# S3 Bucket Name - MUST BE UNIQUE WORLDWIDE!
guardduty_findings_s3_bucket_name = "mycompany-guardduty-findings-2024-dec"

# Security Features - Leave these as "true" unless you have a reason to disable them
enable_guardduty_s3_protection      = true   # Protects your file storage
enable_guardduty_eks_protection     = true   # Protects Kubernetes (if you use it)
enable_guardduty_runtime_monitoring = true   # Monitors running applications
enable_guardduty_malware_protection = true   # Scans for viruses and malware
enable_guardduty_rds_protection     = true   # Protects databases
enable_guardduty_lambda_protection  = true   # Protects serverless functions
retain_malware_snapshots           = true    # Keeps copies when malware is found (for investigation)
enable_ec2_agent_management        = true    # Automatically manages GuardDuty agents on EC2 instances
```

**🚨 CRITICAL**: The S3 bucket name must be unique across ALL AWS accounts worldwide. Make it specific to you:
- ✅ Good: `acmecorp-guardduty-findings-2024-december`
- ✅ Good: `johnsmith-security-logs-20241202`
- ❌ Bad: `guardduty-findings` (too generic, probably taken)

### Step 8: Initialize Terraform (Download the Tools)

**What this does:** Downloads all the AWS-specific tools Terraform needs.

```bash
terraform init
```

**What you should see:**
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.x.x...
Terraform has been successfully initialized!
```

**If you see errors:**
- Make sure you're in the right folder (where the .tf files are)
- Check your internet connection
- Try running the command again

### Step 9: Preview What Will Be Built (Safety Check)

**What this does:** Shows you exactly what Terraform will create before it actually does anything. Like a blueprint review.

```bash
terraform plan
```

**What you should see:**
- A long list of resources that will be created (should be around 15-20 items)
- Lines starting with `+ resource` (these are things being created)
- At the bottom: `Plan: X to add, 0 to change, 0 to destroy`

**Red flags to watch for:**
- Any lines with `- resource` (means something will be deleted - shouldn't happen on first run)
- Error messages about permissions or invalid configurations

**This is your last chance to review before building everything!**

### Step 10: Build Your Security System! 🚀

**This is the big moment - we're actually building everything now!**

```bash
terraform apply
```

**What happens:**
1. Terraform shows you the plan again
2. It asks: `Do you want to perform these actions?`
3. Type `yes` and press Enter
4. Watch the magic happen!

**What you'll see:**
- Lines like `Creating...` and `Creation complete after Xs`
- Progress updates as each piece is built
- At the end: `Apply complete! Resources: X added, 0 changed, 0 destroyed.`

**Timeline:**
- **2-3 minutes**: Most resources are created
- **5-10 minutes**: Everything is fully configured and ready
- **15-30 minutes**: First security findings start appearing

**If something goes wrong:**
- Don't panic! Most issues are permission-related
- Check the error message - it usually tells you exactly what's wrong
- Common fixes are in the Troubleshooting section below

### Step 11: Verify Everything Works (The Victory Lap!)

**Let's make sure your security system is actually running:**

#### Quick Check - GuardDuty
```bash
aws guardduty list-detectors --region us-east-1
```
**You should see:** A detector ID (long string of letters and numbers)

#### Quick Check - Security Hub
```bash
aws securityhub describe-hub --region us-east-1
```
**You should see:** Hub details with status information

#### Quick Check - Inspector
```bash
aws inspector2 batch-get-account-status --region us-east-1
```
**You should see:** Account status showing enabled services

**If any of these fail:**
- Double-check you're using the same region you configured (replace `us-east-1` if needed)
- Make sure the `terraform apply` completed successfully
- Check the Troubleshooting section below

## 🎉 Congratulations! Your Security System is Live!

**What just happened?** You now have enterprise-grade security monitoring running in your AWS account. Here's what to do next:

## See Your Security System in Action

### 1. Check Everything in the AWS Console (The Easy Way)

#### 🛡️ GuardDuty Console (Your Security Guard Dashboard)
1. Log into [AWS Console](https://console.aws.amazon.com)
2. Search for "GuardDuty" and click on it
3. **What you should see:**
   - Green checkmark showing "GuardDuty is enabled"
   - Protection types showing as "Enabled" (S3, Malware, etc.)
   - Findings section (might be empty at first - that's normal!)
4. **Wait 15-30 minutes** for first findings to appear

#### 🔍 Security Hub Console (Your Central Command Center)
1. In AWS Console, search for "Security Hub" and click on it
2. **What you should see:**
   - Dashboard with security score (might start low - that's normal!)
   - "Standards" tab showing 3 enabled standards
   - "Integrations" tab showing GuardDuty and Inspector connected
3. **This is where you'll check your security status daily**

#### 🔎 Inspector Console (Your Vulnerability Scanner)
1. In AWS Console, search for "Inspector" and click on it
2. **What you should see:**
   - "Account status" showing EC2, ECR, and Lambda as "Enabled"
   - "Findings" section (will populate as it scans your resources)
3. **Scans happen automatically** - no action needed from you

### 2. Set Up Notifications (Optional)

To receive alerts for critical findings:

```bash
# Create SNS topic for security alerts
aws sns create-topic --name security-alerts --region us-east-1

# Subscribe your email
aws sns subscribe --topic-arn arn:aws:sns:us-east-1:ACCOUNT-ID:security-alerts --protocol email --notification-endpoint your-email@company.com
```

### 3. Configure Finding Filters (Optional)

Create custom filters in Security Hub to focus on critical findings:
1. Go to Security Hub → Findings
2. Create custom filters for severity levels
3. Set up automated responses using EventBridge

## 💰 What Will This Cost Me? (Honest Breakdown)

**The short answer:** Probably $20-100 per month for most small businesses, but it depends on how much you use AWS.

### Real-World Cost Examples

#### Small Startup (1-5 servers, basic usage)
- **GuardDuty**: $15-30/month
- **Security Hub**: $5-10/month  
- **Inspector**: $5-15/month
- **Total**: ~$25-55/month

#### Medium Business (10-50 servers, moderate usage)
- **GuardDuty**: $50-150/month
- **Security Hub**: $15-30/month
- **Inspector**: $20-50/month  
- **Total**: ~$85-230/month

#### Large Enterprise (100+ servers, heavy usage)
- **GuardDuty**: $200-500/month
- **Security Hub**: $50-100/month
- **Inspector**: $100-300/month
- **Total**: ~$350-900/month

### How Pricing Works (Simple Explanation)

**GuardDuty** charges based on:
- How much data it analyzes (like your internet usage)
- How many API calls your applications make
- How much it scans for malware

**Security Hub** charges based on:
- How many security findings it processes
- How many compliance checks it runs

**Inspector** charges based on:
- How many servers/containers it scans
- How often it scans them

### 💡 Money-Saving Tips
1. **Start small** - disable features you don't need initially
2. **Monitor your bill** - AWS sends monthly usage reports
3. **Use AWS Free Tier** - new accounts get some free usage
4. **Set up billing alerts** - get notified if costs exceed your budget

### Set Up Cost Monitoring (Recommended!)
1. Go to AWS Console → Billing
2. Click "Budgets" → "Create budget"
3. Set a monthly budget (e.g., $100)
4. Add your email for alerts when you hit 80% of budget

## Troubleshooting

### Common Issues

#### 1. S3 Bucket Name Already Exists
```
Error: creating S3 Bucket: BucketAlreadyExists
```
**Solution**: Change the `guardduty_findings_s3_bucket_name` to a unique value.

#### 2. Insufficient Permissions
```
Error: AccessDenied: User is not authorized to perform: guardduty:CreateDetector
```
**Solution**: Ensure your AWS credentials have the required IAM permissions listed above.

#### 3. Region Not Supported
```
Error: InvalidInputException: The request is rejected since GuardDuty is not available in this region
```
**Solution**: Choose a supported region. GuardDuty is available in most major regions.

#### 4. Service Already Enabled
```
Error: BadRequestException: The request is rejected because GuardDuty is already enabled
```
**Solution**: Import existing resources:
```bash
terraform import aws_guardduty_detector.main <existing-detector-id>
```

### Validation Commands

```bash
# Check all services status
aws guardduty list-detectors --region us-east-1
aws securityhub describe-hub --region us-east-1
aws inspector2 batch-get-account-status --region us-east-1

# Check S3 bucket
aws s3 ls | grep guardduty

# Check KMS key
aws kms list-keys --region us-east-1
```

## Maintenance and Monitoring

### Regular Tasks

#### Weekly
- Review GuardDuty findings in the console
- Check Security Hub compliance scores
- Review Inspector vulnerability reports

#### Monthly
- Analyze S3 bucket usage and costs
- Review and tune finding filters
- Update Terraform configuration if needed

#### Quarterly
- Review IAM permissions and access
- Assess cost optimization opportunities
- Update security standards if new versions available

### Updating the Configuration

To modify settings:
1. Edit `terraform.tfvars`
2. Run `terraform plan` to review changes
3. Run `terraform apply` to implement changes

### Backup Important Data

The S3 bucket contains your GuardDuty findings. Consider:
- Enabling S3 Cross-Region Replication
- Setting up lifecycle policies for old findings
- Regular exports for compliance reporting

## Advanced Configuration

### Multi-Region Deployment

To deploy in multiple regions:
1. Create separate Terraform configurations per region
2. Use Terraform workspaces
3. Consider using AWS Organizations for centralized management

### Integration with SIEM

To send findings to external SIEM systems:
1. Set up EventBridge rules for Security Hub findings
2. Configure Lambda functions to forward to SIEM
3. Use AWS Config for additional compliance data

### Automated Remediation

Set up automated responses:
1. Create EventBridge rules for specific finding types
2. Use Lambda functions for automated remediation
3. Implement approval workflows for critical actions

## Cleanup

To remove all resources:

```bash
# Destroy all resources
terraform destroy
```

**⚠️ Warning**: This will delete:
- All security configurations
- The S3 bucket with findings data
- KMS keys (after 7-day waiting period)
- All historical security data

## Getting Help

### AWS Support Resources
- [AWS GuardDuty Documentation](https://docs.aws.amazon.com/guardduty/)
- [AWS Security Hub Documentation](https://docs.aws.amazon.com/securityhub/)
- [AWS Inspector Documentation](https://docs.aws.amazon.com/inspector/)

### Terraform Resources
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform CLI Documentation](https://www.terraform.io/docs/cli/index.html)

### Community Support
- AWS re:Post community forums
- Terraform community forums
- Stack Overflow (use tags: aws, terraform, guardduty, security-hub, inspector)

## Security Best Practices

### After Deployment
1. **Enable MFA** on all AWS accounts
2. **Rotate Access Keys** regularly
3. **Monitor CloudTrail** logs for API activity
4. **Set up Budget Alerts** to monitor costs
5. **Regular Security Reviews** of findings and configurations
6. **Incident Response Plan** for critical security findings
7. **Staff Training** on interpreting and responding to security alerts

This completes your AWS security services deployment. The services will begin monitoring immediately and findings will appear within 15-30 minutes of deployment.