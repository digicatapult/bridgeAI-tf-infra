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

data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

module "mlflow_s3_bucket" {
  count = var.enable_mlflow ? 1 : 0
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = ">= 4.1.2"

  bucket_prefix = "${local.name}-artifacts-"

  force_destroy = false

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
}

module "mlflow_irsa" {
  count = var.enable_mlflow ? 1 : 0
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = ">= 1.1.1"

  create_release = false

  create_role   = true
  create_policy = false

  role_name     = local.service_account
  role_policies = { mlflow_policy = aws_iam_policy.mlflow[0].arn }

  oidc_providers = {
    this = {
      provider_arn    = var.eks_cluster_identity_oidc_issuer_arn
      namespace       = local.namespace
      service_account = local.service_account
    }
  }
}

resource "kubernetes_namespace" "mlflow" {
  metadata {
    name = local.namespace
  }
}

resource "kubernetes_service_account" "mlflow" {
  metadata {
    name        = local.service_account
    namespace   = local.namespace
    annotations = { "eks.amazonaws.com/role-arn" : module.mlflow_irsa[0].iam_role_arn }
  }

  automount_service_account_token = true
}

resource "aws_iam_policy" "mlflow" {
  count = var.enable_mlflow ? 1 : 0
  name_prefix = format("%s-%s-", "mlflow", "policy")
  path        = "/"
  policy      = data.aws_iam_policy_document.mlflow[0].json
}

data "aws_iam_policy_document" "mlflow" {
  count = var.enable_mlflow ? 1 : 0
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:s3:::${module.mlflow_s3_bucket[0].s3_bucket_id}"]

    actions = [
      "s3:ListBucket"
    ]
  }
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:s3:::${module.mlflow_s3_bucket[0].s3_bucket_id}/*"]

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
  }
}
