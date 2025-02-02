# MLFlow
terraform {
  source = "../../../../modules/aws/mlflow/"
}

include {
  path = find_in_parent_folders()
}

dependency "eks" {
  config_path = "../eks"
}

locals {
  default_yaml_path = find_in_parent_folders("env.yaml")

  global = yamldecode(
    file(find_in_parent_folders("env.yaml", local.default_yaml_path))
  )

  eks_vars = read_terragrunt_config(
  find_in_parent_folders("eks/terragrunt.hcl"))
}

inputs = merge(
  local.eks_vars.inputs,
  {
    mlflow_bucket_name    = local.global.mlflow_bucket_name
    dvc_bucket_name       = local.global.dvc_bucket_name
    evidently_bucket_name = local.global.evidently_bucket_name

    eks_cluster_id                       = dependency.eks.outputs.eks_cluster_id
    eks_cluster_identity_oidc_issuer     = dependency.eks.outputs.eks_cluster_identity_oidc_issuer
    eks_cluster_identity_oidc_issuer_arn = dependency.eks.outputs.eks_cluster_identity_oidc_issuer_arn
  }
)
