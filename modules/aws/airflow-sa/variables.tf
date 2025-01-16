variable "region" {
  type = string
}

variable "eks_cluster_id" {
  type = string
}

variable "policy_arns" {
  type = list(any)

}
variable "eks_cluster_identity_oidc_issuer" {
  type = string
}


variable "kubeconfig_path" {
  type    = string
  default = "~/.kube/config"
}

locals {


  account_id = data.aws_caller_identity.current.account_id

  kubeconfig_context = "arn:aws:eks:${var.region}:${local.account_id}:cluster/${var.eks_cluster_id}"
}
