terraform {
    source = "git@github.com:Institute/infrastructure-modules.git//aurora_mysql" #?ref=sns-v0.0.1"
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
  
    name = "user-management-service"
    apply_immediately = true
    copy_tags_to_snapshot = true
    backup_retention_period = 1
    engine = "aurora-mysql"
    engine_mode = "provisioned"
    instances = {
      1 = {
        identifier      = "user-management-service-1"
        instance_class = "db.t4g.medium"
        publicly_accessible = false
      }
    }
    final_snapshot_identifier = "user-management-service"
    kms_key_id = dependency.kms.outputs.key_arn
    vpc_id = include.env.locals.vpc_id
    security_group_name = "user-management-service-aurora"
    create_db_cluster_parameter_group      = true
    db_cluster_parameter_group_name        = "user-management-service"
    db_cluster_parameter_group_family      = "aurora-mysql8.0"
    security_group_rules = {
        ingress_from_dataplane_subnet1 = {
          type        = "ingress"
          from_port   = 3306
          to_port     = 3306
          protocol    = "tcp"
          description = "HTTP web traffic"
          cidr_blocks = [include.env.locals.eks_dataplane_subnet_az1_cidr]
        }
        ingress_from_dataplane_subnet2 = {
          type        = "ingress"
          from_port   = 3306
          to_port     = 3306
          protocol    = "tcp"
          description = "HTTP web traffic"
          cidr_blocks = [include.env.locals.eks_dataplane_subnet_az2_cidr]
        }
        ingress_from_dataplane_subnet3 = {
          type        = "ingress"
          from_port   = 3306
          to_port     = 3306
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
    subnets = [include.env.locals.db_subnet_az1, include.env.locals.db_subnet_az2, include.env.locals.db_subnet_az3]
    db_subnet_group_name = "user-management-service"
    skip_final_snapshot = true
    create_db_parameter_group = true
    create_db_subnet_group = true
    db_parameter_group_family = "aurora-mysql8.0"
    manage_master_user_password = false
    master_user_secret_kms_key_id = dependency.kms.outputs.key_arn
    master_username = "root"
    port = 3306
    deletion_protection = true
    service_name = "user-management-service"
    team_name    = "URM"
    environment  = include.env.locals.environment_name
    launched_by  = "terraform"
  
  }
