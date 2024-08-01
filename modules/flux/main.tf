provider "github" {
  owner = var.github_org
}

provider "flux" {
  kubernetes = {
    host                   = var.cluster_host
    cluster_ca_certificate = var.cluster_cert
  }

  git = {
    url = "ssh://git@github.com/${var.github_org}/${var.github_repository}"

    ssh = {
      username    = var.github_user
      private_key = var.github_private_key
    }

    branch = var.github_branch
  }
}

provider "kubernetes" {
  host                   = var.cluster_host
  cluster_ca_certificate = var.cluster_cert

  exec {
    api_version = "client.authentication.k8s.io/v1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
  }
}

resource "github_repository" "this" {
  name       = var.github_repository
  visibility = "private"

  auto_init = var.auto_init
}

resource "flux_bootstrap_git" "flux" {
  interval             = "10m"
  namespace            = "flux-system"
  path                 = var.flux_path
  version              = var.flux_version
  secret_name          = var.flux_secret_name

  delete_git_manifests = var.delete_git_manifests
  embedded_manifests   = var.embedded_manifests

  toleration_keys      = ["NoSchedule"]

  components = [
    "source-controller",
    "kustomize-controller",
    "helm-controller",
    "notification-controller"
  ]

  depends_on = [
    github_repository.this
  ]
}
