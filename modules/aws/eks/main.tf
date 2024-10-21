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

module "label" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  attributes = ["cluster"]

  context = module.this.context
}

module "eks_cluster" {
  source                    = "cloudposse/eks-cluster/aws"
  version                   = "4.2.0"

  addons_depends_on     = [module.eks_node_group]
  stage                 = var.stage
  region                = var.region
  namespace             = local.namespace
  oidc_provider_enabled = var.oidc_provider_enabled
  kubernetes_version    = var.kubernetes_version
  subnet_ids            = var.cluster_private_subnets_only ? var.private_az_subnet_ids : concat(
    var.private_az_subnet_ids, var.public_az_subnet_ids)

  enabled_cluster_log_types = [
    "api", "audit", "authenticator", "controllerManager", "scheduler"]

  context = module.this.context
}

module "eks_node_group" {
  source                            = "cloudposse/eks-node-group/aws"
  version                           = "3.0.1"

  namespace                         = local.namespace
  desired_size                      = var.desired_size
  min_size                          = var.min_size
  max_size                          = var.max_size
  ami_type                          = var.ami_type
  instance_types                    = var.instance_types
  capacity_type                     = var.capacity_type
  kubernetes_labels                 = var.kubernetes_labels
  kubernetes_version                = [var.kubernetes_version]
  subnet_ids                        = var.private_az_subnet_ids
  cluster_name                      = module.eks_cluster.eks_cluster_id
  create_before_destroy             = true

  block_device_mappings = [{
    device_name           = "/dev/xvda"
    volume_size           = 100
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }]

  context = module.this.context
}

module "eks_node_group_large" {
  source                            = "cloudposse/eks-node-group/aws"
  version                           = "3.0.1"

  namespace                         = "${local.namespace}-1"
  desired_size                      = 3
  min_size                          = 1
  max_size                          = 5
  ami_type                          = var.ami_type
  instance_types                    = ["t3.large"]
  capacity_type                     = var.capacity_type
  kubernetes_labels                 = var.kubernetes_labels
  kubernetes_version                = [var.kubernetes_version]
  subnet_ids                        = var.private_az_subnet_ids
  cluster_name                      = module.eks_cluster.eks_cluster_id
  create_before_destroy             = true

  block_device_mappings = [{
    device_name           = "/dev/xvda"
    volume_size           = 100
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }]

  context = module.this.context

  tags = {
    "Attributes"  = "workers"
    "Environment" = "test"
    "Name"        = "mlops-test-workers"
    "Namespace"   = "mlops"
  }
}

module "eks_node_group_2xlarge" {
  source                            = "cloudposse/eks-node-group/aws"
  version                           = "3.0.1"

  namespace                         = "${local.namespace}-2"
  desired_size                      = 1
  min_size                          = 1
  max_size                          = 1
  ami_type                          = var.ami_type
  instance_types                    = ["t3.2xlarge"]
  capacity_type                     = var.capacity_type
  kubernetes_labels                 = var.kubernetes_labels
  kubernetes_version                = [var.kubernetes_version]
  subnet_ids                        = var.private_az_subnet_ids
  cluster_name                      = module.eks_cluster.eks_cluster_id
  create_before_destroy             = true

  block_device_mappings = [{
    device_name           = "/dev/xvda"
    volume_size           = 100
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }]

  context = module.this.context

  tags = {
    "Attributes"  = "workers"
    "Environment" = "test"
    "Name"        = "mlops-test-workers"
    "Namespace"   = "mlops"
  }
}
