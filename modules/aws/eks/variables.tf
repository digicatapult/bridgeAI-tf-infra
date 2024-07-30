variable "availability_zones" {
  type        = list(string)
}

variable "kubernetes_version" {
  type        = string
  default     = "1.30"
}

variable "kubernetes_labels" {
  type        = map(string)
  default     = {}
}

variable "instance_types" {
  type        = list(string)
}

variable "desired_size" {
  type        = number
}

variable "ami_type" {
  type        = string
}

variable "capacity_type" {
  type        = string
}

variable "max_size" {
  type        = number
}

variable "min_size" {
  type        = number
}

variable "environment" {
  type        = string
}

variable "profile"  {
  type        = string
}

variable "project" {
  type        = string
}

variable "region" {
  type        = string
}

variable "vpc_id" {}

variable "cidr_block" {
  type        = string
}

variable "private_ipv6_enabled" {
  type        = bool
  default     = false
}

variable "public_az_subnet_ids" {
  type        = list(any)
}

variable "private_az_subnet_ids" {
  type        = list(any)
}

variable "enabled_cluster_log_types" {
  type        = list(string)
  default     = []
}

variable "cluster_log_retention_period" {
  type        = number
  default     = 0
}

variable "oidc_provider_enabled" {
  type        = bool
  default     = true
}

variable "cluster_private_subnets_only" {
  type        = bool
  default     = false
}

variable "cluster_encryption_config_enabled" {
  type        = bool
  default     = true
}

variable "cluster_encryption_config_kms_key_id" {
  type        = string
  default     = ""
}

variable "cluster_encryption_config_kms_key_enable_key_rotation" {
  type        = bool
  default     = true
}

variable "cluster_encryption_config_kms_key_deletion_window_in_days" {
  type        = number
  default     = 10
}

variable "cluster_encryption_config_kms_key_policy" {
  type        = string
  default     = null
}

variable "cluster_encryption_config_resources" {
  type        = list(any)
  default     = ["secrets"]
}

variable "enable_addons" {
  type        = bool
  default     = false
}

variable "addons" {
  type = list(object({
    addon_name    = string
    addon_version = string

    resolve_conflicts           = optional(string, null)
    resolve_conflicts_on_create = optional(string, null)
    resolve_conflicts_on_update = optional(string, null)
    service_account_role_arn    = string
  }))
}

locals {
  namespace   = "${var.project}"

  tags = { "kubernetes.io/cluster/${module.label.id}" = "shared" }

  public_subnets_additional_tags = {
    "kubernetes.io/role/elb" : 1
  }
  private_subnets_additional_tags = {
    "kubernetes.io/role/internal-elb" : 1
  }
}
