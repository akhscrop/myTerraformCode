terraform {
  source = "git@github.com:Institute/infrastructure-modules.git//kms" #?ref=sns-v0.0.1"
}

include "root" {
  path = find_in_parent_folders()
}

include "env"{
  path = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

include "region"{
  path = find_in_parent_folders("region.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

dependency "irsa_role" {
  config_path = "../iam_role_for_service_account/"
  mock_outputs = { iam_role_arn = "role_arn" }
}

dependency "irsa_role_2" {
  config_path = "../../vod_tencent_callback_worker/iam_role_for_service_account/"
  mock_outputs = { iam_role_arn = "role_arn" }
}

include "account"{
  path = find_in_parent_folders("account.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

inputs = {
  description = "vod_service"
  key_owners                    = ["${include.env.locals.AWSReservedSSO_AdministratorAccess_role_arn}"]
  key_administrators           = [get_aws_caller_identity_arn()]
  key_users                     = [dependency.irsa_role.outputs.iam_role_arn,dependency.irsa_role_2.outputs.iam_role_arn]
  enable_default_policy                  = true
  aliases = ["vod_service"]
  key_statements = [
    {
      sid = "CloudWatchLogs"
      actions = [
        "kms:Encrypt*",
        "kms:Decrypt*",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:Describe*"
      ]
      resources = ["*"]

      principals = [
        {
          type        = "Service"
          identifiers = ["logs.${include.region.locals.aws_region}.amazonaws.com"]
        }
      ]

      conditions = [
        {
          test     = "ArnLike"
          variable = "kms:EncryptionContext:aws:logs:arn"
          values = [
            "arn:aws:logs:${include.region.locals.aws_region}:${include.account.locals.aws_account_number}:log-group:*",
          ]
        }
      ]
    },
    {
      sid = "Allow Amazon SNS to use this key"
      actions = [
         "kms:Decrypt",
         "kms:GenerateDataKey*"
      ]
      resources = ["*"]

      principals = [
        {
          type        = "Service"
          identifiers = ["sns.amazonaws.com"]
        }
      ]
    }
  ]
  service_name = "vod-service"
  team_name    = "CDE"
  environment  = include.env.locals.environment_name
  launched_by  = "terraform"

}

