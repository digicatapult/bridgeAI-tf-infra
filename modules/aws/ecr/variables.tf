variable "profile"  {
  type        = string
}

variable "region" {
  type        = string
}

variable "ecr_repository_name" {
    type      = string
}

variable "eks_cluster_identity_oidc_issuer" {
  type        = string
}

variable "eks_cluster_identity_oidc_issuer_arn" {
  type        = string
}

locals {
  account_id = data.aws_caller_identity.current.account_id

  oidc_provider = replace(var.eks_cluster_identity_oidc_issuer, "https://", "")
}
