generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<EOF
provider "aws" {
  region  = "ap-south-1"
#  profile = "default"
  
  assume_role {
    session_name = "terraform"
    role_arn = "arn:aws:iam::937360******:role/JenkinsTerraformDeploymentAdminRole"
  }
}
EOF
}

remote_state {
  backend = "s3"
  generate = {
    path      = "state.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
#    profile = "default"
    role_arn = "arn:aws:iam::537984*****:role/JenkinsTerraformDeploymentAdminRole"
    bucket = "akhil-terraform-state-dev-account"

    key = "${path_relative_to_include()}/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-lock-table"
  }
}