# bridgeAI-tf-infra

This repository is intended to spin up a single EKS cluster with minimal AWS infrastructure for the purposes of an MLOps demonstrator in September 2024, as part of Digital Catapult's [BridgeAI][bridgeai] deliverables. That cluster will be Kind-based and use GitOps principles, courtesy of either Flux2 or ArgoCD, with several MLOps pipeline components, such as Apache Airflow and MLFlow, to run through a DAG.

All infrastructure will be stood up on a single AWS account: "digicat-mlops-demo".


## Dependencies

Terraform/Terragrunt version management (`tfenv`/`tgenv`):

```bash
brew install tfenv tgenv
tfenv -v; tgenv -v
tfenv install 1.7.3; tgenv install 0.55.3
```

The AWS CLI (`awscli`):

```bash
brew install awscli
aws --version
aws configure
```

The EKS CLI (`eksctl`):

```bash
brew install eksctl
eksctl version
```

AWS credentials for Kubernetes (`aws-iam-authenticator`):

```bash
brew install aws-iam-authenticator
aws-iam-authenticator version
```

Kubernetes command-line management (`kubectl`):

```bash
brew install kubectl
kubectl version --client
```

FluxCD `flux`:

```bash
brew install fluxcd/tap/flux
flux version
flux check
```

To install and bootstrap FluxCD via Terraform, the user will also require adminitrator privileges within the target GitHub organisation.


## Quick start

Clone the repository:

```bash
git clone https://github.com/digicatapult/bridgeai-tf-infra/
```

Initialise the backend:

```bash
cd bridgeai-tf-infra/env/test
terragrunt plan
```

Deploy all AWS infrastructure modules, one after the other:

```bash
cd aws/vpc
terragrunt apply
cd ../eks
terragrunt apply
```

Retrieve the AWS credentials to configure `kubectl` on a workstation:

```bash
aws eks --region eu-west-2 update-kubeconfig --name mlops-test-cluster
```

The above command, if successful, should write the new context to `$HOME/.kube/config`.

Verify that the remote context is correct:

```bash
kubectl config get-contexts
```


## Structure

Our modules are split between AWS and Flux2, between official sources and third-party developers, such as [Cloud Posse][cloudposse].

In terms of structure, the environments will mostly comprise Terragrunt (HCL) and YAML, while the infrastructure modules should be all Terraform:

```bash
├── env
│   └── test
│       ├── aws
│       │   ├── cert-manager
│       │   ├── ecr
│       │   ├── eks
│       │   ├── external-dns
│       │   ├── mlflow
│       │   └── vpc
└── modules
    ├── aws
    │   ├── cert-manager
    │   ├── ecr
    │   ├── eks
    │   ├── external-dns
    │   ├── mlflow
    │   └── vpc
```

There is a single environment in the tree above, notionally called 'test', for testing the infrastructure with Terragrunt. Environments should be initialised with their own specific variables, provided in `./env/test/env.yaml` in this case, which are then parsed by `terragrunt.hcl`. When `terragrunt apply` is used recursively against each subdirectory under `./env/test`, the inputs and variables will serve to initialise and configure infrastructure for that particular environment.

To create new environments, 'prod' for example, copy an existing `./env/*` subdirectory, change the variables in the YAML and review the inputs and sourced modules mentioned in the Terragrunt HCL. If there are new dependencies, then ensure that those are initialised and online before proceeding. Once ready, run the following in the same subdirectory:

```bash
terragrunt plan
```


## Development

Since Terraform 1.6.0, it has been possible to mock deployment without the need for cloud platform credentials, such as AWS access keys. This allows developers to test the creation of resources, validation of providers, or sourcing of additional configuration all without cost. The testing framework relies on the `terraform test` subcommand and has its own syntax.

Unit testing is also covered in HashiCorp's [testing documentation][tests].

While not a prerequisite, [Terraformer][terraformer] may also prove useful when making changes to live infrastructure and then needing to export those alterations as TF code within the original project. That can simplify the writing of any infrastructure-as-code, particularly where support in off-the-shelf modules is inadequate for the project's needs. A complete list of supported AWS services can be found under `./docs` within the above Terraformer repository.


## Environment variables

A single YAML file defines the bulk of environment variables for the backend, project, and the respective clusters and node groups.

```yaml
# Backend
bucket: "tfstate-mlops-test"
dynamodb_table: "terraform-state-locks"
```

Both `bucket` and `dynamodb_table` variables are utilised in the root HCL for the environment; the bucket name ought to be environment-specific.

```yaml
# Project
availability_zones: ["eu-west-2a", "eu-west-2b"]
cidr_block: "10.155.48.0/20"
environment: "test"
profile: "digicat-mlops"
project: "mlops"
region: "eu-west-2"
stage: "pipeline"
bucket_prefix: "bridgeai"
mlflow_bucket_name: "model-artefacts"
dvc_bucket_name: "dvc-remote"
evidently_bucket_name: "evidently-reports"
```

At least two availability zones are needed for the EKS' API call `CreateCluster`, hence the above example includes "eu-west-2a" and "eu-west-2b". Given the above, the CIDR block likely ought to be sufficiently large enough to be able to distinguish public and private subnets across the different zones.

```yaml
# Clusters
ami_type: "AL2_x86_64_GPU"
capacity_type: "ON_DEMAND"
desired_size: 1
kubernetes_version: "1.30"
instance_types: ["g4dn.xlarge"]
max_size: 1
min_size: 1
```

These variables configure the lone cluster and its node groups. A complete listing of supported AMIs and capacity types can be found in the EKS API [Nodegroup reference sheet][nodegroup]. The [Instance Type Explorer][explorer] provides detail on the EC2 types best suited to high-performance computation, including solvers and inference-based MLOps pipelines. Size variables relate to the upper and lower bounds for when autoscaling nodes, the desired size being the value the group should maintain.


<!-- Links -->
[bridgeai]: https://iuk.ktn-uk.org/programme/bridgeai/
[cloudposse]: https://registry.terraform.io/namespaces/cloudposse
[cloudposse-repository]: https://github.com/cloudposse/terraform-aws-components
[tests]: https://developer.hashicorp.com/terraform/language/tests
[nodegroup]: https://docs.aws.amazon.com/eks/latest/APIReference/API_Nodegroup.html
[terraformer]: https://github.com//terraformer/blob/master/docs/aws.md
[explorer]: https://aws.amazon.com/ec2/instance-explorer/
[addons]: https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html
[aws-ia]: https://github.com/aws-ia
