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
  count  = "${length(var.bucket_list)}"
  source  = "cloudposse/s3-bucket/aws"
  version = ">= 4.7.0"

  name = "${var.bucket_prefix}-${var.bucket_list[count.index]}"

  s3_object_ownership = "BucketOwnerEnforced"
  enabled             = true
  user_enabled        = false
  versioning_enabled  = true
}

module "aws_iam_role" {
  count                         = "${length(var.bucket_list)}"
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.43.0"
  create_role                   = true
  role_name                     = "${var.bucket_list[count.index]}-bucket-access-role"
  provider_url                  = replace(var.eks_cluster_identity_oidc_issuer, "https://", "")
  role_policy_arns              = [aws_iam_policy.artifacts[count.index].arn]
  oidc_fully_qualified_subjects = [
    "system:serviceaccount:${var.namespace_list[count.index]}:${var.service_account_list[count.index]}"
  ]
}

resource "kubernetes_namespace" "this" {
  for_each = {
    for i,v in var.namespace_list: i=>v
  }
  metadata {
    name = "${var.namespace_list[each.key]}"
  }
}

resource "aws_iam_policy" "artifacts" {
  count  = "${length(var.bucket_list)}"
  name   = "${var.bucket_list[count.index]}-bucket-access-policy"
  policy = data.aws_iam_policy_document.access[count.index].json
}

data "aws_iam_policy_document" "access" {
  count  = "${length(var.bucket_list)}"
  statement {
    sid       = "listBucket"
    effect    = "Allow"
    resources = try(["arn:aws:s3:::${var.bucket_prefix}-${var.bucket_list[count.index]}/*"])

    actions = [
      "s3:ListBucket",
      "s3:ListBucketVersions"
    ]
  }
  statement {
    sid       = "useObject"
    effect    = "Allow"
    resources = try(["arn:aws:s3:::${var.bucket_prefix}-${var.bucket_list[count.index]}/*"])

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
  }
}
