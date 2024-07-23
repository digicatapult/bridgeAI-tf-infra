# VPC
terraform {
  source = "../../../../modules/aws/vpc/"
}

include {
  path = find_in_parent_folders()
}

locals {
  default_yaml_path = find_in_parent_folders("env.yaml")

  global = yamldecode(
    file(find_in_parent_folders("env.yaml", local.default_yaml_path))
  )
}

inputs = {
  availability_zones          = local.global.availability_zones
  cidr_block                  = local.global.cidr_block
  environment                 = local.global.environment
  profile                     = local.global.profile
  project                     = local.global.project
  region                      = local.global.region
  terraform_state_bucket_name = local.global.bucket
}
