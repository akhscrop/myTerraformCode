terraform {
  source = "git@github.com:Institute/infrastructure-modules.git//eks_resources" #?ref=sns-v0.0.1"
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
  config_path = "../eks"
  mock_outputs = {eks_cluster_name = "eks_cluster_name", eks_cluster_certificate_authority_data = "eks_cluster_certificate_authority_data", eks_cluster_endpoint = "eks_cluster_endpoint" }
}

dependency "temporal_db" {
  config_path = "../temporal_db/aurora_mysql"
  mock_outputs = { temporal_db_host = "temporal_db_host" }
}

dependency "temporal_irsa" {
  config_path = "../temporal_db/iam_role_for_service_account"
  mock_outputs = { iam_role_arn = "iam_role_arn" }
}

inputs = {

  JenkinsTerraformDeploymentAdminRole  = include.env.locals.JenkinsTerraformDeploymentAdminRole
  eks_cluster_endpoint = dependency.eks.outputs.eks_cluster_endpoint
  eks_cluster_certificate_authority_data = dependency.eks.outputs.cluster_certificate_authority_data
  eks_cluster_name = dependency.eks.outputs.eks_cluster_name
  argo_parent_app = "argo_crds_root_app"
  acm_certificate_arn = include.env.locals.acm_certificate_arn
  values_file_name = "values-${include.env.locals.environment_name}.yaml"
  temporal_db_host = dependency.temporal_db.outputs.cluster_endpoint
  temporal_db_password =dependency.temporal_db.outputs.random_password
  temporal_service_account_role = dependency.temporal_irsa.outputs.iam_role_arn
  subnet_ids = [include.env.locals.eks_dataplane_subnet_az1, include.env.locals.eks_dataplane_subnet_az2, include.env.locals.eks_dataplane_subnet_az3]

}