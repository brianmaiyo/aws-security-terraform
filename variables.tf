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

variable "enable_inspector" {
  description = "Enable AWS Inspector"
  type        = bool
  default     = true
}

variable "enable_inspector_lambda" {
  description = "Enable Inspector Lambda scanning (may not be available in all regions)"
  type        = bool
  default     = true
}