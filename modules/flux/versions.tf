terraform {
  required_version = ">= 1.7.3"

  required_providers {
    flux = {
      source  = "fluxcd/flux"
      version = ">= 1.3.0"
    }

    github = {
      source  = "integrations/github"
      version = ">= 6.2.3"
    }

    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.5"
    }
  }
}
