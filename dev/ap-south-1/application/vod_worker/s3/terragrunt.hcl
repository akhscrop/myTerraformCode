terraform {
  source = "git@github.com:Institute/infrastructure-modules.git//s3" #?ref=sns-v0.0.1"
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

dependency "irsa_role" {
  config_path = "../iam_role_for_service_account/"
  mock_outputs = { iam_role_arn = "role_arn" }
}

include "region"{
  path = find_in_parent_folders("region.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

inputs = {
  attach_policy = true
  bucket = "vod-worker"
  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "Policy1689597854584",
    "Statement": [
      {
        "Sid": "Stmt1689597849822",
        "Effect": "Allow",
        "Principal": {
          "AWS": "${dependency.irsa_role.outputs.iam_role_arn}"
        },
        "Action": "s3:*",
        "Resource": "arn:aws:s3:::${include.region.locals.aws_region}-${include.env.locals.environment_name}-vod-worker/*"
      }
    ]
  }
  EOF
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = dependency.kms.outputs.key_id
        sse_algorithm     = "aws:kms"
      }
    }
  }
  service_name = "vod-worker"
  team_name    = "CDE"
  environment  = include.env.locals.environment_name
  launched_by  = "terraform"

}
