terraform {
  source = "git@github.com:Institute/infrastructure-modules.git//karpenter" #?ref=sns-v0.0.1"
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
  mock_outputs = {eks_oidc_id = "eks_oidc_id", eks_cluster_name = "eks_cluster_name", eks_cluster_certificate_authority_data = "eks_cluster_certificate_authority_data", eks_cluster_endpoint = "eks_cluster_endpoint" }
}

inputs = {

  JenkinsTerraformDeploymentAdminRole  = include.env.locals.JenkinsTerraformDeploymentAdminRole
  eks_cluster_endpoint = dependency.eks.outputs.eks_cluster_endpoint
  eks_cluster_certificate_authority_data = dependency.eks.outputs.cluster_certificate_authority_data
  eks_cluster_name = dependency.eks.outputs.eks_cluster_name
  eks_oidc_id = dependency.eks.outputs.eks_oidc_id
  subnet_ids = [include.env.locals.eks_dataplane_subnet_az1, include.env.locals.eks_dataplane_subnet_az2, include.env.locals.eks_dataplane_subnet_az3]
  cluster_arn = dependency.eks.outputs.cluster_arn
  node_security_group_id = dependency.eks.outputs.node_security_group_id
  service_name = "karpenter"
  team_name    = "shared"
  environment  = include.env.locals.environment_name
  launched_by  = "terraform"
}