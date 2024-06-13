terraform {
  source = "git@github.com:Institute/infrastructure-modules.git//sns" #?ref=sns-v0.0.1"
}

include "root" {
  path = find_in_parent_folders()
}

include "env"{
  path = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

dependency "sqs" {
  config_path = "../sqs/"
  mock_outputs = { queue_arn = "queue_arn" }
}

dependency "kms" {
  config_path = "../kms/"
  mock_outputs = { key_id = "key_id" }
}

dependency "irsa_role" {
  config_path = "../iam_role_for_service_account/"
  mock_outputs = { iam_role_arn = "role_arn" }
}

inputs = {

  name = "user-management-service"

  subscriptions = {
    sqs = {
      protocol = "sqs"
      endpoint = dependency.sqs.outputs.queue_arn
    }
  }
  kms_master_key_id = dependency.kms.outputs.key_id
  create_topic_policy         = true
  enable_default_topic_policy = false
  topic_policy_statements = {
    pub = {
      actions = ["sns:Publish"]
      principals = [{
        type        = "AWS"
        identifiers = [dependency.irsa_role.outputs.iam_role_arn]
      }]
    }
  }
  
  service_name = "user-management-service"
  team_name    = "URM"
  environment  = include.env.locals.environment_name
  launched_by  = "terraform"

}

