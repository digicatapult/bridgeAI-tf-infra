provider "aws" {
  region = var.region
  profile = var.profile
}

module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes = ["cluster"]

  context = module.this.context
}

module "vpc" {
  source  = "cloudposse/vpc/aws"
  version = "2.2.0"

  tags                    = local.tags
  ipv4_primary_cidr_block = var.cidr_block

  ipv4_cidr_block_association_timeouts = {
    create = "3m"
    delete = "5m"
  }

  context = module.this.context
}

module "subnets" {
  source  = "cloudposse/dynamic-subnets/aws"
  version = "2.0.4"

  availability_zones   = var.availability_zones
  vpc_id               = module.vpc.vpc_id
  igw_id               = [module.vpc.igw_id]
  ipv4_cidr_block      = [module.vpc.vpc_cidr_block]
  nat_gateway_enabled  = "true"
  nat_instance_enabled = "false"
  stage                = var.stage

  namespace                       = local.namespace
  private_subnets_additional_tags = local.private_subnets_additional_tags
  public_subnets_additional_tags  = local.public_subnets_additional_tags

  context = module.this.context
}
