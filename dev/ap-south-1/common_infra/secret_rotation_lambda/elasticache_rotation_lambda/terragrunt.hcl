# terraform {
#   source = "git@github.com:Institute/infrastructure-modules.git//secret_rotation_lambda" #?ref=sns-v0.0.1"
# }

# include "root" {
#   path = find_in_parent_folders()
# }

# include "env"{
#   path = find_in_parent_folders("env.hcl")
#   expose         = true
#   merge_strategy = "no_merge"
# }

# inputs = {
#   function_name      = "elasticache_secret_rotation_function"
#   handler            = "function.lambda_handler"
#   runtime            = "python3.10"
#   timeout            = 300
#   memory_size        = 512
#   package_path = "./elasticache_secret_rotation_function/elasticache_function.zip"
#   attach_policy_json = true
#   policy_json        = {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#         "Effect": "Allow",
#         "Action": [
#             "secretsmanager:UpdateSecretVersionStage",
#             "secretsmanager:PutSecretValue",
#             "secretsmanager:GetSecretValue",
#             "secretsmanager:DescribeSecret",
#             "elasticache:ModifyUser",
#             "elasticache:DescribeUsers"
#         ],
#         "Resource": "*"
#         },
#         {
#         "Effect": "Allow",
#         "Action": [
#             "kms:Decrypt",
#             "kms:DescribeKey",
#             "kms:GenerateDataKey"
#         ],
#         "Resource": "*"
#         },
#         {
#         "Effect": "Allow",
#         "Action": "secretsmanager:GetRandomPassword",
#         "Resource": "*"
#         },
#         {
#         "Effect": "Allow",
#         "Action": [
#             "logs:PutLogEvents",
#             "logs:CreateLogStream",
#             "logs:CreateLogGroup"
#         ],
#         "Resource": "*"
#         }
#     ]
#   }
#   publish            = false
#   vpc_subnet_ids = [include.env.locals.eks_dataplane_subnet_az1, include.env.locals.eks_dataplane_subnet_az2, include.env.locals.eks_dataplane_subnet_az3]
#   attach_network_policy = true
#   allowed_triggers = {
#     secrets = {
#       principal = "secretsmanager.amazonaws.com"
#     }
#   }
#   environment_variables = {
#     "SECRETS_MANAGER_ENDPOINT" = "https://secretsmanager.ap-south-1.amazonaws.com"
#   }
#   create_security_group = true
#   security_group_name = "elasticache_secret_rotation_function"
#   vpc_id = include.env.locals.vpc_id
#   security_group_rules = {
#     ingress_all_http = {
#       type        = "ingress"
#       from_port   = 6379
#       to_port     = 6379
#       protocol    = "tcp"
#       description = "HTTP web traffic"
#       cidr_blocks = [include.env.locals.vpc_cidr]
#     }
#     egress_all = {
#       type        = "egress"
#       from_port   = 0
#       to_port     = 0
#       protocol    = "-1"
#       cidr_blocks = ["0.0.0.0/0"]
#     }
#   }
#   environment = include.env.locals.environment_name
#   service_name = "shared"
#   launched_by = "terraform"
#   team_name = "shared"
# }