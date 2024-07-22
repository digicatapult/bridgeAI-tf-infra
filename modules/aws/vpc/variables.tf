variable "cidr_block" {}
variable "environment" {}
variable "profile" {}
variable "project" {}
variable "public_key" {}
variable "region" {}
variable "terraform_state_bucket_name" {}
variable "availability_zones" {
  type = list(string)
}

locals {
  namespace = "${var.project}"

  tags = merge(
    module.label.tags, tomap(
      { "kubernetes.io/cluster/${module.label.id}" = "shared" }))

  public_subnets_additional_tags = {
    "kubernetes.io/role/elb" : 1
  }
  private_subnets_additional_tags = {
    "kubernetes.io/role/internal-elb" : 1
  }
}
