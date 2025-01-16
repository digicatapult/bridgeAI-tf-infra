provider "aws" {
  region = var.region
}

provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = local.kubeconfig_context
}

data "aws_caller_identity" "current" {}

module "aws_iam_role_with_oidc" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.43.0"
  create_role                   = true
  role_name                     = "airflow-access-role"
  provider_url                  = replace(var.eks_cluster_identity_oidc_issuer, "https://", "")
  role_policy_arns              = [var.policy_arns[0], var.policy_arns[1], var.policy_arns[2]]
  oidc_fully_qualified_subjects = ["system:serviceaccount:airflow:airflow"]
}