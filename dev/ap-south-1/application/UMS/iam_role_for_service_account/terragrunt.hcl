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

  custom_policy_name = "user_management_service_account_role_policy"
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
      "elasticache:connect",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "appconfig:*"
		],
		"Resource": "*"
    }
  ]
}
EOF

  role_name = "user_management_service_account_role"
 
  create_role = true
  oidc_id = dependency.eks.outputs.eks_oidc_id
  service_account_namespace = "user-management"
  service_account_name = "user-management-service-sa"
  service_name = "user-management-service"
  team_name    = "URM"
  environment  = include.env.locals.environment_name
  launched_by  = "terraform"

}

