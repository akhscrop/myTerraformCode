terraform {
  source = "git@github.com:Allen-Career-Institute/allen-infrastructure-modules.git//vpc_endpoints" #?ref=sns-v0.0.1"
}

include "root" {
  path = find_in_parent_folders()
}

include "env"{
  path = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

inputs = {
  vpc_id = include.env.locals.vpc_id
  create_security_group      = true
  security_group_name_prefix = "${include.env.locals.environment_name}-vpc-endpoints"
  security_group_rules = {
    ingress_https = {
      description = "HTTPS from VPC"
      cidr_blocks = [include.env.locals.vpc_cidr]
    }
  }
  endpoints = {
    ssm = {
      service             = "ssm"
      private_dns_enabled = true
      subnet_ids          = [include.env.locals.eks_dataplane_subnet_az1, include.env.locals.eks_dataplane_subnet_az2, include.env.locals.eks_dataplane_subnet_az3]
    }
    ssmmessages = {
      service             = "ssmmessages"
      private_dns_enabled = true
      subnet_ids          = [include.env.locals.eks_dataplane_subnet_az1, include.env.locals.eks_dataplane_subnet_az2, include.env.locals.eks_dataplane_subnet_az3]
    }
    ec2-messasges = {
      service             = "ec2messages"
      private_dns_enabled = true
      subnet_ids          = [include.env.locals.eks_dataplane_subnet_az1, include.env.locals.eks_dataplane_subnet_az2, include.env.locals.eks_dataplane_subnet_az3]
    }
    sns = {
      service             = "sns"
      private_dns_enabled = true
      subnet_ids          = [include.env.locals.eks_dataplane_subnet_az1, include.env.locals.eks_dataplane_subnet_az2, include.env.locals.eks_dataplane_subnet_az3]
    }
    sqs = {
      service             = "sqs"
      private_dns_enabled = true
      subnet_ids          = [include.env.locals.eks_dataplane_subnet_az1, include.env.locals.eks_dataplane_subnet_az2, include.env.locals.eks_dataplane_subnet_az3]
    }
    secretsmanager = {
      service             = "secretsmanager"
      private_dns_enabled = true
      subnet_ids          = [include.env.locals.eks_dataplane_subnet_az1, include.env.locals.eks_dataplane_subnet_az2, include.env.locals.eks_dataplane_subnet_az3]
    }
    ecr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
      subnet_ids          = [include.env.locals.eks_dataplane_subnet_az1, include.env.locals.eks_dataplane_subnet_az2, include.env.locals.eks_dataplane_subnet_az3]
    }
    dynamodb = {
      service         = "dynamodb"
      service_type    = "Gateway"
      route_table_ids = [include.env.locals.staging_EKSDataPlaneSubnetRouteTable]
      policy          = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": "dynamodb:*",
      "Resource": "*",
      "Principal": {
        "AWS": "*"
      }
    }
  ]
}
EOF
      tags            = { Name = "dynamodb-vpc-endpoint" }
    }
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = [include.env.locals.staging_EKSDataPlaneSubnetRouteTable]
      policy          = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*",
      "Principal": {
        "AWS": "*"
      }
    }
  ]
}
EOF
tags            = { Name = "s3-vpc-endpoint" }
    },
  }
  service_name = "eks"
  team_name    = "terraform"
  environment  = include.env.locals.environment_name
  launched_by  = "terraform"
}