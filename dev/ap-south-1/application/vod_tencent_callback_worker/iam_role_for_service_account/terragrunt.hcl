terraform {
  source = "git@github.com:Institute/infrastructure-modules.git//iam_role_for_service_account" #?ref=sns-v0.0.1"
}

include "root" {
  path = find_in_parent_folders()
}

include "env"{
  path = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

dependency "eks" {
  config_path = "../../../common_infra/eks"
  mock_outputs = { eks_oidc_id = "1234567890" }
}

inputs = {

  custom_policy_name = "vod_tencent_callback_worker_account_role_policy"
  role_policy_arns = []
  custom_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
		"Effect": "Allow",
		"Action": [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "appconfig:*"
		],
		"Resource": "*"
    }
  ]
}
EOF

  role_name = "vod_tencent_callback_worker_account_role"
 
  create_role = true
  oidc_id = dependency.eks.outputs.eks_oidc_id
  service_account_namespace = "vod-tencent-callback-worker"
  service_account_name = "vod-tencent-callback-worker-sa"
  service_name = "vod-tencent-callback-worker"
  team_name    = "CDE"
  environment  = include.env.locals.environment_name
  launched_by  = "terraform"

}

