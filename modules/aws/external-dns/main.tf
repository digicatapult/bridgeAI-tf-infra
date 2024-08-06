provider "aws" {
  region = var.region
}

provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = local.kubeconfig_context
}

provider "helm" {
  kubernetes {
    config_path    = var.kubeconfig_path
    config_context = local.kubeconfig_context
  }
}

data "aws_caller_identity" "current" {}

data "aws_route53_zone" "this" {
  name    = var.domain
}

module "eks-external-dns" {
  source  = "lablabs/eks-external-dns/aws"
  version = "1.2.0"

  cluster_identity_oidc_issuer = var.eks_cluster_identity_oidc_issuer
  cluster_identity_oidc_issuer_arn = var.eks_cluster_identity_oidc_issuer_arn

  settings = {
    "source[0]" = "service"
    "source[1]" = "ingress"
    "coredns.etcdTLS.enabled" = "false"
    "domainFilters[0]" = data.aws_route53_zone.this.name
    "policy" = "sync"
  }
}
