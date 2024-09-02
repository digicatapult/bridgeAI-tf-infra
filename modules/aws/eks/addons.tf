module "eks_blueprints_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.16.3"

  cluster_name      = module.eks_cluster.eks_cluster_id
  cluster_endpoint  = module.eks_cluster.eks_cluster_endpoint
  cluster_version   = module.eks_cluster.eks_cluster_version
  oidc_provider_arn = local.oidc_arn


  eks_addons = {
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn
    }

  #enable_aws_efs_csi_driver                    = true
  enable_aws_ebs_csi_driver                    = true
  tags = local.tags
}
}
module "ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.20"

  role_name_prefix = "mlops-ebs-csi-driver-"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = local.oidc_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = local.tags
}