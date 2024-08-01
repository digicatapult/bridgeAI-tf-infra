# Flux
terraform {
  source = "../../../modules/flux"
}

dependency "eks" {
  config_path = "../aws/eks"
}

locals {
  default_yaml_path = find_in_parent_folders("env.yaml")

  global = yamldecode(
    file(find_in_parent_folders("env.yaml", local.default_yaml_path))
  )

  eks_vars = read_terragrunt_config(
    find_in_parent_folders("aws/eks/terragrunt.hcl"))
}

inputs = merge(
  local.eks_vars.inputs,
  {
    flux_path        = local.global.flux_path
    flux_version     = local.global.flux_version
    flux_secret_name = local.global.flux_secret_name

    github_org         = local.global.github_org
    github_repository  = local.global.github_repository
    github_branch      = local.global.github_branch
    github_user        = local.global.github_user
    github_private_key = local.global.github_private_key

    cluster_name = dependency.eks.outputs.eks_cluster_id
    cluster_cert = base64decode(
      dependency.eks.outputs.eks_cluster_certificate_authority_data)
    cluster_host = dependency.eks.outputs.eks_cluster_endpoint
  }
)
