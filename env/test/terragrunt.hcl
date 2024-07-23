locals {
    bucket = local.env["bucket"]
    dynamodb_table = local.env["dynamodb_table"]
    env = yamldecode(file("env.yaml"))
    profile = local.env["profile"]
    region = local.env["region"]
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }

  config = {
    encrypt        = true
    bucket         = "${local.bucket}"
    profile        = "${local.profile}"
    region         = "${local.region}"
    dynamodb_table = "${local.dynamodb_table}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
  }
}
