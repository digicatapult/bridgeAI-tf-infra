# EKS
terraform {
  source = "../../../../modules/aws/eks/"
}

include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
}

locals {
  default_yaml_path = find_in_parent_folders("env.yaml")

  global = yamldecode(
    file(find_in_parent_folders("env.yaml", local.default_yaml_path))
  )

  vpc_vars = read_terragrunt_config(
    find_in_parent_folders("aws/vpc/terragrunt.hcl"))
}

inputs = merge(
  local.vpc_vars.inputs,
  {
    ami_type           = local.global.ami_type
    capacity_type      = local.global.capacity_type
    desired_size       = local.global.desired_size
    instance_types     = local.global.instance_types
    kubernetes_version = local.global.kubernetes_version
    max_size           = local.global.max_size
    min_size           = local.global.min_size

    private_az_subnet_ids = dependency.vpc.outputs.private_az_subnet_ids
    public_az_subnet_ids  = dependency.vpc.outputs.public_az_subnet_ids
    vpc_id                = dependency.vpc.outputs.vpc_id
  }
)
