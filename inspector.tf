# Enable Inspector V2
resource "aws_inspector2_enabler" "ec2" {
  account_ids    = [data.aws_caller_identity.current.account_id]
  resource_types = ["EC2"]
}

# Note: ECR and Lambda enablers may timeout in some regions
# resource "aws_inspector2_enabler" "ecr" {
#   account_ids    = [data.aws_caller_identity.current.account_id]
#   resource_types = ["ECR"]
# }

# resource "aws_inspector2_enabler" "lambda" {
#   account_ids    = [data.aws_caller_identity.current.account_id]
#   resource_types = ["LAMBDA"]
# }

# Inspector Configuration for EC2 scanning (Hybrid mode)
# Note: Organization configuration requires AWS Organizations management account
# resource "aws_inspector2_organization_configuration" "main" {
#   auto_enable {
#     ec2    = true
#     ecr    = true
#     lambda = true
#   }
# }

# Inspector Delegated Admin Account (if using Organizations)
# Uncomment if you want to set up delegated admin
# resource "aws_inspector2_delegated_admin_account" "main" {
#   account_id = data.aws_caller_identity.current.account_id
# }