variable "region" {
  type        = string
}

variable "environment" {
  type        = string
}

variable "namespace" {
  type        = string
  default     = "mlflow"
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

variable "enable_mlflow" {
  type        = bool
  default     = true
}

locals {
  account_id = data.aws_caller_identity.current.account_id

  kubeconfig_context = "arn:aws:eks:${var.region}:${local.account_id}:cluster/${var.eks_cluster_id}"

  name            = "mlflow"
  namespace       = "mlflow"
  service_account = "mlflow"
}
