provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

# Create the ECR repository
resource "aws_ecr_repository" "init" {
  name = var.ecr_repository_name
}

resource "aws_ecr_repository_policy" "init" {
  repository = aws_ecr_repository.init.name
  policy     = data.aws_iam_policy_document.init.json
}

# Define overarching repository policies on creation
data "aws_iam_policy_document" "init" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["${local.account_id}"]
    }

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchDeleteImage",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:SetRepositoryPolicy",
      "ecr:UploadLayerPart",
    ]
  }
}

# Provide read-only access for synchronising credentials
module "aws_iam_read_only_access" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.43.0"
  create_role                   = true
  role_name                     = "ecr-credentials-sync-role"
  provider_url                  = local.oidc_provider
  role_policy_arns              = ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]
  oidc_fully_qualified_subjects = ["system:serviceaccount:flux-system:ecr-credentials-sync"]
}

# Provide pull permissions for inference services
module "aws_iam_pull_access" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.43.0"
  create_role                   = true
  role_name                     = "inference-sa-role"
  provider_url                  = local.oidc_provider
  role_policy_arns              = [aws_iam_policy.pull.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kserve:inference-sa"]
}

resource "aws_iam_policy" "pull" {
  name   = "inference-service-pull-policy"
  policy = data.aws_iam_policy_document.pull.json
}

data "aws_iam_policy_document" "pull" {
  statement {
    effect = "Allow"

    resources = try(
      ["arn:aws:ecr:${var.region}:${local.account_id}:repository/${var.ecr_repository_name}/*"]
    )

    actions = [
      "ecr:CompleteLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:BatchGetImage"
    ]
  }
}
