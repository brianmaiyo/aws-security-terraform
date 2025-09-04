# Inspector EC2 scanning - using comprehensive regional logic
resource "aws_inspector2_enabler" "ec2" {
  count = local.inspector_services.enable_ec2 ? 1 : 0

  account_ids    = [data.aws_caller_identity.current.account_id]
  resource_types = ["EC2"]

  timeouts {
    create = "25m"
    update = "25m"
    delete = "25m"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      # Ignore changes that might cause unnecessary recreation
      account_ids
    ]
  }
}

# Inspector ECR scanning - using comprehensive regional logic
resource "aws_inspector2_enabler" "ecr" {
  count = local.inspector_services.enable_ecr ? 1 : 0

  account_ids    = [data.aws_caller_identity.current.account_id]
  resource_types = ["ECR"]

  timeouts {
    create = "25m"
    update = "25m"
    delete = "25m"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      # Ignore changes that might cause unnecessary recreation
      account_ids
    ]
  }

  # Add dependency to ensure EC2 enabler completes first
  depends_on = [aws_inspector2_enabler.ec2]
}

# Inspector Lambda scanning - using comprehensive regional logic
resource "aws_inspector2_enabler" "lambda" {
  count = local.inspector_services.enable_lambda ? 1 : 0

  account_ids    = [data.aws_caller_identity.current.account_id]
  resource_types = ["LAMBDA"]

  timeouts {
    create = "25m"
    update = "25m"
    delete = "25m"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      # Ignore changes that might cause unnecessary recreation
      account_ids
    ]
  }

  # Add dependency to ensure other enablers complete first
  depends_on = [aws_inspector2_enabler.ec2, aws_inspector2_enabler.ecr]
}