variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "security-services"
}

variable "guardduty_findings_s3_bucket_name" {
  description = "S3 bucket name for GuardDuty findings"
  type        = string
  default     = null
}

variable "enable_guardduty_s3_protection" {
  description = "Enable GuardDuty S3 protection"
  type        = bool
  default     = true
}

variable "enable_guardduty_eks_protection" {
  description = "Enable GuardDuty EKS protection"
  type        = bool
  default     = true
}

variable "enable_guardduty_runtime_monitoring" {
  description = "Enable GuardDuty runtime monitoring"
  type        = bool
  default     = true
}

variable "enable_guardduty_malware_protection" {
  description = "Enable GuardDuty malware protection"
  type        = bool
  default     = true
}

variable "enable_guardduty_rds_protection" {
  description = "Enable GuardDuty RDS protection"
  type        = bool
  default     = true
}

variable "enable_guardduty_lambda_protection" {
  description = "Enable GuardDuty Lambda protection"
  type        = bool
  default     = true
}

variable "retain_malware_snapshots" {
  description = "Retain scanned snapshots when malware is detected"
  type        = bool
  default     = true
}

variable "enable_ec2_agent_management" {
  description = "Enable EC2 agent management for GuardDuty runtime monitoring and malware protection"
  type        = bool
  default     = true
}