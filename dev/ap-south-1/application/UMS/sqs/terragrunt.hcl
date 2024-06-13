terraform {
  source = "git@github.com:Institute/infrastructure-modules.git//sqs" #?ref=sns-v0.0.1"
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

include "account"{
  path = find_in_parent_folders("account.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

inputs = {

  name = "user-management-service"
  create_queue_policy = true
  sqs_managed_sse_enabled = false
  kms_master_key_id = dependency.kms.outputs.key_id
  queue_policy_statements = {
    account = {
      sid = "AccountReadWrite"
      actions = [
        "sqs:SendMessage",
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage"
      ]
      principals = [
        {
          type        = "AWS"
          identifiers = ["arn:aws:iam::${include.account.locals.aws_account_number}:root"]
        }
      ]
    }
    sns = {
      sid     = "SNS"
      actions = ["sqs:SendMessage"]

      principals = [
        {
          type        = "Service"
          identifiers = ["sns.amazonaws.com"]
        }
      ]
    }
  }

  service_name = "user-management-service"
  team_name    = "URM"
  environment  = include.env.locals.environment_name
  launched_by  = "terraform"

}

