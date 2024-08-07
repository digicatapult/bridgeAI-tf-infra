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

data "aws_route53_zone" "this" {
  name    = var.domain
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "issuers" {
  statement {
    sid       = "getChange"
    actions   = ["route53:GetChange"]
    resources = ["arn:aws:route53:::change/*"]
  }
  statement {
    sid       = "recordSets"
    actions   = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets"
    ]
    resources = ["arn:aws:route53:::hostedzone/*"]
  }
  statement {
    sid       = "listHostedZone"
    actions   = ["route53:ListHostedZonesByName"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "issuers" {
  name   = "cert-manager-issuers"
  policy = data.aws_iam_policy_document.issuers.json
}

resource "kubernetes_config_map" "config" {
  metadata {
    name      = "cert-manager-config"
    namespace = "cert-manager"
  }

  data = {
    cert_manager_irsa_role_arn = module.cert_manager_irsa.iam_role_arn
    zone_id                    = data.aws_route53_zone.this.zone_id
  }
}

module "cert_manager_irsa" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.43.0"
  create_role                   = true
  role_name                     = "cert-manager-requests"
  provider_url                  = replace(var.eks_cluster_identity_oidc_issuer, "https://", "")
  role_policy_arns              = [aws_iam_policy.issuers.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:cert-manager:cert-manager"]
}
