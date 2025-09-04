# Data sources for dynamic configuration
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

# Get available availability zones (useful for multi-AZ deployments)
data "aws_availability_zones" "available" {
  state = "available"
}