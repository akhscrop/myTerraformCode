terraform {
  source = "git@github.com:Institute/infrastructure-modules.git//elasticache" #?ref=sns-v0.0.1"
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

inputs = {

  replication_group_id = "user-management-service"
  engine = "redis"
  replication_group_description = "user-management-service"
  node_type            = "cache.t4g.small"
  num_node_groups      = 1
  snapshot_retention_limit = 0
  replicas_per_node_group = 0
  kms_key_id = dependency.kms.outputs.key_arn
  automatic_failover_enabled = true
  create_security_group = true
  security_group_name = "user-management-service-elasticache"
  vpc_id = include.env.locals.vpc_id
  create_parameter_group = true
  parameter_group_name = "user-management-service"
  parameter_group_family = "redis7"
  parameter_group_parameters = [{
    "name" : "cluster-enabled"
    "value" : "yes"
  }]
  create_subnet_group = true
  subnet_group_subnet_ids     = [include.env.locals.elasticache_subnet_az1, include.env.locals.elasticache_subnet_az2, include.env.locals.elasticache_subnet_az3]
  subnet_group_name = "user-management-service"
  password_protected_user_id = "user-management-service"
  user_group_id = "user-management-service"
  security_group_rules = {
    ingress_from_dataplane_subnet1 = {
      type        = "ingress"
      from_port   = 6379
      to_port     = 6379
      protocol    = "tcp"
      description = "HTTP web traffic"
      cidr_blocks = [include.env.locals.eks_dataplane_subnet_az1_cidr]
    }
    ingress_from_dataplane_subnet2 = {
      type        = "ingress"
      from_port   = 6379
      to_port     = 6379
      protocol    = "tcp"
      description = "HTTP web traffic"
      cidr_blocks = [include.env.locals.eks_dataplane_subnet_az2_cidr]
    }
    ingress_from_dataplane_subnet3 = {
      type        = "ingress"
      from_port   = 6379
      to_port     = 6379
      protocol    = "tcp"
      description = "HTTP web traffic"
      cidr_blocks = [include.env.locals.eks_dataplane_subnet_az3_cidr]
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  service_name = "user-management-service"
  team_name    = "URM"
  environment  = include.env.locals.environment_name
  launched_by  = "terraform"
  
}

