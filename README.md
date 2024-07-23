# bridgeAI-tf-infra

This repository is intended to spin up a single EKS cluster with minimal AWS infrastructure for the purposes of an MLOps demonstrator in September 2024, as part of Digital Catapult's [BridgeAI][bridgeai] deliverables. That cluster will be Kind-based and use GitOps principles, courtesy of either Flux2 or ArgoCD, with several MLOps pipeline components, such as Apache Airflow and MLFlow, to run through a DAG.

All infrastructure will be stood up on a single AWS account: "digicat-mlops-demo".


## Dependencies
- Terraform/Terragrunt version management (`tfenv`/`tgenv`):

```bash
brew install tfenv tgenv
tfenv -v; tgenv -v
tfenv install 1.7.3; tgenv install 0.55.3
```

- The AWS CLI (`awscli`):

```bash
brew install awscli
aws --version
aws configure
```

- AWS credentials for Kubernetes (`aws-iam-authenticator`):

```bash
brew install aws-iam-authenticator
aws-iam-authenticator version
```

- Kubernetes command-line management (`kubectl`):

```bash
brew install kubectl
kubectl version --client
```


## Structure

Our modules are split between Amazon, GitHub, and Flux2, between official sources and [Cloud Posse][cloudposse], a DevOps company and AWS provider that develops its own blueprints.

In terms of structure, the environments will mostly comprise Terragrunt (HCL) and YAML, while the infrastructure modules should be all Terraform:

```bash
├── env
│   └── test
│       ├── aws
│       │   ├── eks
│       │   └── vpc
│       ├── flux
│       └── github
└── modules
    ├── aws
    │   ├── eks
    │   └── vpc
    ├── flux
    └── github
```

There is a single environment in the tree above, notionally called 'test', for testing the infrastructure with Terragrunt. Environments should be initialised with their own specific variables, provided in `./env/test/env.yaml` in this case, which are then parsed by `terragrunt.hcl`. When `terragrunt apply` is used recursively against each subdirectory under `./env/test`, the inputs and variables will serve to initialise and configure infrastructure for that particular environment.

To create new environments, 'prod' for example, copy an existing `./env/*` subdirectory, change the variables in the YAML and review the inputs and sourced modules mentioned in the Terragrunt HCL. If there are new dependencies, then ensure that those are initialised and online before proceeding. Once ready, run the following in the same subdirectory:

```bash
terragrunt plan
```


## Development

Since Terraform 1.6.0, it has been possible to mock deployment without the need for cloud platform credentials, such as AWS access keys. This allows developers to test the creation of resources, validation of providers, or sourcing of additional configuration all without cost. The testing framework relies on the `terraform test` subcommand and has its own syntax.

Unit testing is also covered in HashiCorp's [testing documentation][tests].

<!-- Links -->
[bridgeai]: https://iuk.ktn-uk.org/programme/bridgeai/
[cloudposse]: https://registry.terraform.io/namespaces/cloudposse
[tests]: https://developer.hashicorp.com/terraform/language/tests
