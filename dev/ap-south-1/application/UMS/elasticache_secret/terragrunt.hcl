terraform {
  source = "git@github.com:Institute/infrastructure-modules.git//secret_manager" #?ref=sns-v0.0.1"
}

include "root" {
  path = find_in_parent_folders()
}

include "env"{
  path = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

dependency "kms" {
  config_path = "../kms/"
  mock_outputs = { key_id = "key_id" }
}

dependency "elasticache" {
  config_path = "../elasticache/"
  mock_outputs = { random_password = "random_password", aws_elasticache_password_authenticated_user_arn = "aws_elasticache_password_authenticated_user_arn" }
}

# dependency "elasticache_rotation_lambda" {
#   config_path = "../../../common_infra/secret_rotation_lambda/elasticache_rotation_lambda/"
#   mock_outputs = { lambda_function_arn = "lambda_function_arn" }
# }

dependency "irsa_role" {
  config_path = "../iam_role_for_service_account/"
  mock_outputs = { iam_role_arn = "iam_role_arn" }
}

inputs = {

  name = "user-management-service-elasticache"
  recovery_window_in_days = 7
  kms_key_id = dependency.kms.outputs.key_id
  create_policy       = true
  block_public_policy = true
  policy_statements = {
    # lambda = {
    #   sid = "LambdaReadWrite"
    #   principals = [{
    #     type        = "AWS"
    #     identifiers = [dependency.elasticache_rotation_lambda.outputs.lambda_role_arn]
    #   }]
    #   actions = [
    #     "secretsmanager:DescribeSecret",
    #     "secretsmanager:GetSecretValue",
    #     "secretsmanager:PutSecretValue",
    #     "secretsmanager:UpdateSecretVersionStage",
    #   ]
    #   resources = ["*"]
    # }
    account = {
      sid = "AccountDescribe"
      principals = [{
        type        = "AWS"
        identifiers =  [dependency.irsa_role.outputs.iam_role_arn]
      }]
      actions   = [        
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetSecretValue",
      ]
      resources =  ["*"]
    }
  }
  ignore_secret_changes = true
  enable_rotation     = false
#   rotation_lambda_arn = dependency.elasticache_rotation_lambda.outputs.lambda_function_arn
#   rotation_rules = {
#     # This should be more sensible in production
#     schedule_expression = "rate(30 days)"
#   }
  
  ## secret_string template for elasticache 
  secret_string = jsonencode({
    username = "default",
    password = dependency.elasticache.outputs.random_password,
    user_arn = dependency.elasticache.outputs.aws_elasticache_password_authenticated_user_arn
  })

  service_name = "user-management-service"
  team_name    = "URM"
  environment  = include.env.locals.environment_name
  launched_by  = "terraform"

}

