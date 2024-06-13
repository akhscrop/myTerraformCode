terraform {
  source = "git@github.com:Institute/infrastructure-modules.git//eks" #?ref=sns-v0.0.1"
}

include "root" {
  path = find_in_parent_folders()
}

include "env"{
  path = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}


include "account"{
  path = find_in_parent_folders("account.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

inputs = {

    cluster_name                         = "eks"
    cluster_version                      = "1.27"
    domain_name                        = include.env.locals.domain_name
    acm_certificate_arn = include.env.locals.acm_certificate_arn
    vpc_id                               = include.env.locals.vpc_id
    subnet_ids                           = [include.env.locals.eks_dataplane_subnet_az1, include.env.locals.eks_dataplane_subnet_az2, include.env.locals.eks_dataplane_subnet_az3]
    control_plane_subnet_ids             = [include.env.locals.eks_controlplane_subnet_az1, include.env.locals.eks_controlplane_subnet_az2, include.env.locals.eks_controlplane_subnet_az3]
    JenkinsTerraformDeploymentAdminRole  = include.env.locals.JenkinsTerraformDeploymentAdminRole
    eks_managed_node_groups = {
      eks_managed_initial_ng = {
        instance_types = ["c6a.2xlarge"]
    
        min_size     = 2
        max_size     = 5
        desired_size = 3
    
        iam_role_additional_policies = {
          AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
          AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        }
        
        block_device_mappings = {
          xvda = {
            device_name = "/dev/xvda"
            ebs = {
              volume_size           = 150
              volume_type           = "gp3"
              delete_on_termination = true
            }
          }
        }
      }
    }
    aws_auth_roles = [
       {
        rolearn  = "${include.env.locals.AWSReservedSSO_AdministratorAccess_role_arn}"
        username = "admins"
        groups = [
          "system:masters"
        ]
      }
    ]
    aws_auth_users = [
      {
        userarn  = "arn:aws:iam::${include.account.locals.aws_account_number}:user/saurabh.jain"
        username = "saurabh.jain"
        groups = [
          "system:masters"
        ]
      },
      {
        userarn  = "arn:aws:iam::${include.account.locals.aws_account_number}:user/dharshan.ks"
        username = "saurabh.jain"
        groups = [
          "system:masters"
        ]
      },
      {
        userarn  = "arn:aws:iam::${include.account.locals.aws_account_number}:user/lakshay.sharma"
        username = "saurabh.jain"
        groups = [
          "system:masters"
        ]
      },
      {
        userarn  = "arn:aws:iam::${include.account.locals.aws_account_number}:user/akhil.srivastava"
        username = "saurabh.jain"
        groups = [
          "system:masters"
        ]
      },
      {
        userarn  = "arn:aws:iam::${include.account.locals.aws_account_number}:user/suresh.d"
        username = "suresh.d"
        groups = [
          "system:masters"
        ]
      }
    ]
    service_name = "eks"
    team_name    = "terraform"
    environment  = include.env.locals.environment_name
    launched_by  = "terraform"
}

