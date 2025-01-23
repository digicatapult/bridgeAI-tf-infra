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

resource "kubernetes_namespace" "mlflow" {
  metadata {
    name = "mlflow"
  }
}

data "aws_caller_identity" "current" {}

module "s3_bucket" {
  count   = length(local.bucket_list)
  source  = "cloudposse/s3-bucket/aws"
  version = ">= 4.7.0"

  name = "${var.bucket_prefix}-${local.bucket_list[count.index]}"

  s3_object_ownership = "BucketOwnerEnforced"
  enabled             = true
  user_enabled        = false
  versioning_enabled  = true
}

module "aws_iam_role_with_oidc" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.43.0"
  create_role                   = true
  role_name                     = "mlflow-bucket-access-role"
  provider_url                  = replace(var.eks_cluster_identity_oidc_issuer, "https://", "")
  role_policy_arns              = [aws_iam_policy.this[0].arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:mlflow:mlflow-tracking"]
}

module "aws_iam_role_without_oidc" {
  source                  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version                 = "5.43.0"
  create_role             = true
  role_name               = "dvc-bucket-access-role"
  custom_role_policy_arns = [aws_iam_policy.this[1].arn, aws_iam_policy.this[2].arn]
  trusted_role_arns       = ["arn:aws:iam::${local.account_id}:root"]
}

resource "aws_iam_policy" "this" {
  count  = length(local.bucket_list)
  name   = "${local.bucket_list[count.index]}-bucket-access-policy"
  policy = data.aws_iam_policy_document.this[count.index].json
}

data "aws_iam_policy_document" "this" {
  count = length(local.bucket_list)
  statement {
    sid       = "listBucket"
    effect    = "Allow"
    resources = try(["arn:aws:s3:::${var.bucket_prefix}-${local.bucket_list[count.index]}"])

    actions = [
      "s3:ListBucket",
      "s3:ListBucketVersions"
    ]
  }
  statement {
    sid       = "useObject"
    effect    = "Allow"
    resources = try(["arn:aws:s3:::${var.bucket_prefix}-${local.bucket_list[count.index]}/*"])

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
  }
}

resource "aws_iam_user" "mlflow-s3" {
  name = "mlflow-s3"
}

resource "aws_iam_user_policy_attachment" "mlflow-s3" {
  user       = aws_iam_user.mlflow-s3.name
  policy_arn = aws_iam_policy.this[0].arn
}

resource "aws_iam_access_key" "mlflow-s3" {
  user = aws_iam_user.mlflow-s3.name
}

resource "kubernetes_secret" "mlflow-s3" {
  metadata {
    name      = "mlflow-s3"
    namespace = kubernetes_namespace.mlflow.id
  }

  data = {
    access_key_id     = aws_iam_access_key.mlflow-s3.id
    secret_access_key = aws_iam_access_key.mlflow-s3.secret
  }
}