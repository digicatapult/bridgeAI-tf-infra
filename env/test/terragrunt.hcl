locals {
    env = yamldecode(file("env.yaml"))
    region = local.env["region"]
    dynamodb_table = local.env["dynamodb_table"]
    bucket = local.env["bucket"]
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
    region         = "${local.region}"
    dynamodb_table = "${local.dynamodb_table}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
  }
}
