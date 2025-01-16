# Airflow-SA
terraform {
  source = "../../../../modules/aws/airflow-sa/"
}

include {
  path = find_in_parent_folders()
}

dependency "eks" {
  config_path = "../eks"
}

dependency "mlflow" {
  config_path = "../mlflow"
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
    policy_arns = [
      dependency.mlflow.outputs.policy_arn[0],
      dependency.mlflow.outputs.policy_arn[1],
      dependency.mlflow.outputs.policy_arn[2]
    ]
    eks_cluster_id                       = dependency.eks.outputs.eks_cluster_id
    eks_cluster_identity_oidc_issuer     = dependency.eks.outputs.eks_cluster_identity_oidc_issuer
    eks_cluster_identity_oidc_issuer_arn = dependency.eks.outputs.eks_cluster_identity_oidc_issuer_arn
  }
)
