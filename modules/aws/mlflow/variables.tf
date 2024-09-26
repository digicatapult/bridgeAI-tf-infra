variable "region" {
  type        = string
}

variable "bucket_prefix" {
  type        = string
  default     = "bridgeai"
}

variable "mlflow_bucket_name" {
  type        = string
}

variable "dvc_bucket_name" {
  type        = string
}

variable "evidently_bucket_name" {
  type        = string
}

variable "eks_cluster_id" {
    type      = string
}

variable "eks_cluster_identity_oidc_issuer" {
  type        = string
}

variable "eks_cluster_identity_oidc_issuer_arn" {
  type        = string
}

variable "kubeconfig_path" {
    type      = string
    default   = "~/.kube/config"
}

locals {
  bucket_list = [
    var.mlflow_bucket_name,
    var.dvc_bucket_name,
    var.evidently_bucket_name
  ]

  account_id = data.aws_caller_identity.current.account_id

  kubeconfig_context = "arn:aws:eks:${var.region}:${local.account_id}:cluster/${var.eks_cluster_id}"
}
