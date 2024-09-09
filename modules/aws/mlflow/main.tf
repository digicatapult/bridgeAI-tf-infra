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

module "s3_bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = ">= 4.7.0"

  name = "bridgeai-mlflow-artifacts-storage"

  s3_object_ownership = "BucketOwnerEnforced"
  enabled             = true
  user_enabled        = false
  versioning_enabled  = false
}

module "mlflow_irsa" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.43.0"
  create_role                   = true
  role_name                     = "mlflow-artifacts-requests"
  provider_url                  = replace(var.eks_cluster_identity_oidc_issuer, "https://", "")
  role_policy_arns              = [aws_iam_policy.artifacts.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:mlflow:mlflow"]
}

resource "kubernetes_namespace" "mlflow" {
  metadata {
    name = "mlflow"
  }
}

resource "aws_iam_policy" "artifacts" {
  name   = "mlflow-artifact-access-policy"
  policy = data.aws_iam_policy_document.artifacts.json
}

data "aws_iam_policy_document" "artifacts" {
  statement {
    sid       = "listBucket"
    effect    = "Allow"
    resources = ["arn:aws:s3:::${module.s3_bucket.bucket_id}"]

    actions = [
      "s3:ListBucket"
    ]
  }
  statement {
    sid       = "useObject"
    effect    = "Allow"
    resources = ["arn:aws:s3:::${module.s3_bucket.bucket_id}/*"]

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
  }
}
