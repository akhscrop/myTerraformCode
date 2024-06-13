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

dependency "aurora_mysql" {
  config_path = "../aurora_mysql/"
  mock_outputs = { random_password = "random_password", cluster_endpoint = "cluster_endpoint" , cluster_master_username = "cluster_master_username" }
}

dependency "irsa_role" {
  config_path = "../iam_role_for_service_account/"
  mock_outputs = { iam_role_arn = "iam_role_arn" }
}

inputs = {

  name = "user-management-service-mysql"
  recovery_window_in_days = 7
  kms_key_id = dependency.kms.outputs.key_id
  create_policy       = true
  block_public_policy = true
  policy_statements = {
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
  
  ## secret_string template for aurora_mysql 
  secret_string = jsonencode({
    host = dependency.aurora_mysql.outputs.cluster_endpoint,
    username = dependency.aurora_mysql.outputs.cluster_master_username,
    password = dependency.aurora_mysql.outputs.random_password,
  })

    service_name = "user-management-service"
    team_name    = "URM"
    environment  = include.env.locals.environment_name
    launched_by  = "terraform"

}

