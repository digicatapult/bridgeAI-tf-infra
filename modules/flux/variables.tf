variable "region" {
  type        = string
}

variable "cluster_host" {
  type        = string
}

variable "cluster_cert" {
  type        = string
}

variable "cluster_name" {
  type        = string
}

variable "github_org" {
  type        = string
}

variable "github_repository" {
  type        = string
}

variable "github_branch" {
  type        = string
  default     = "feature/eks_terraform"
}

variable "github_user" {
  type        = string
}

variable "github_private_key" {
  type        = string
}

variable "flux_path" {
  type        = string
}

variable "flux_secret_name" {
  type        = string
  default     = "sops-gpg"
}

variable "flux_version" {
  type        = string
  default     = "v2.3.0"
}

variable "auto_init" {
  type        = bool
  default     = false
}

variable "delete_git_manifests" {
  type        = bool
  default     = false
}

variable "embedded_manifests" {
  type        = bool
  default     = false
}
