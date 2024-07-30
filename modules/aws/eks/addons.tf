locals {
  eks_cluster_oidc_issuer_url = module.eks_cluster.eks_cluster_identity_oidc_issuer
  eks_cluster_id              = module.eks_cluster.eks_cluster_id

  addon_names                = [for k, v in var.addons : k if var.enable_addons]
  aws_ebs_csi_driver_enabled = contains(local.addon_names, "aws-ebs-csi-driver")
  aws_efs_csi_driver_enabled = contains(local.addon_names, "aws-efs-csi-driver")

  ebs_csi_sa_needed = local.aws_ebs_csi_driver_enabled ? lookup(var.addons["aws-ebs-csi-driver"], "service_account_role_arn", null) == null : false
  efs_csi_sa_needed = local.aws_efs_csi_driver_enabled ? lookup(var.addons["aws-efs-csi-driver"], "service_account_role_arn", null) == null : false
  addon_service_account_role_arn_map = {
    aws-ebs-csi-driver = module.aws_ebs_csi_driver_eks_iam_role.service_account_role_arn
    aws-efs-csi-driver = module.aws_efs_csi_driver_eks_iam_role.service_account_role_arn
  }

  addons = [
    for k, v in var.addons : {
      addon_name                  = k
      addon_version               = lookup(v, "addon_version", null)
      configuration_values        = lookup(v, "configuration_values", null)
      resolve_conflicts_on_create = lookup(v, "resolve_conflicts_on_create", null)
      resolve_conflicts_on_update = lookup(v, "resolve_conflicts_on_update", null)
      service_account_role_arn    = try(coalesce(lookup(v, "service_account_role_arn", null), lookup(local.addon_service_account_role_arn_map, k, null)), null)
      create_timeout              = lookup(v, "create_timeout", null)
      update_timeout              = lookup(v, "update_timeout", null)
      delete_timeout              = lookup(v, "delete_timeout", null)
    }
  ]

  addons_depends_on = concat([
    module.aws_ebs_csi_driver_eks_iam_role,
    module.aws_efs_csi_driver_eks_iam_role,]
  )
}

resource "aws_iam_role_policy_attachment" "aws_ebs_csi_driver" {
  count = local.ebs_csi_sa_needed ? 1 : 0

  role       = module.aws_ebs_csi_driver_eks_iam_role.service_account_role_name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

module "aws_ebs_csi_driver_eks_iam_role" {
  source  = "cloudposse/eks-iam-role/aws"
  version = "2.1.1"

  enabled = local.ebs_csi_sa_needed

  eks_cluster_oidc_issuer_url = local.eks_cluster_oidc_issuer_url

  service_account_name      = "ebs-csi-controller-sa"
  service_account_namespace = "kube-system"

  context = module.this.context
}

resource "aws_iam_role_policy_attachment" "aws_efs_csi_driver" {
  count = local.efs_csi_sa_needed ? 1 : 0

  role       = module.aws_efs_csi_driver_eks_iam_role.service_account_role_name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
}

module "aws_efs_csi_driver_eks_iam_role" {
  source  = "cloudposse/eks-iam-role/aws"
  version = "2.1.1"

  enabled = local.efs_csi_sa_needed

  eks_cluster_oidc_issuer_url = local.eks_cluster_oidc_issuer_url

  service_account_namespace_name_list = [
    "kube-system:efs-csi-controller-sa",
    "kube-system:efs-csi-node-sa",
  ]

  context = module.this.context
}
