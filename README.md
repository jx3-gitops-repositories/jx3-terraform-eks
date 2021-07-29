# EKS Terraform Quickstart template

Use this template to easily create a new Git Repository for managing Jenkins X cloud infrastructure needs.

We recommend using Terraform to manage the infrastructure needed to run Jenkins X. 
There can be a number of cloud resources which need to be created such as:
- Kubernetes cluster
- Storage buckets for long term storage of logs
- IAM Bindings to manage permissions for applications using cloud resources

Jenkins X likes to use GitOps to manage the lifecycle of both infrastructure and cluster resources.  
This requires two git Repositories to achieve this:
- the first, infrastructure resources will be managed by Terraform and will keep resourecs in sync.
- the second, the Kubernetes specific cluster resources will be managed by Jenkins X and keep resources in sync.

# Prerequisites

- A Git organisation that will be used to create the GitOps repositories used for Jenkins X below.
  e.g. https://github.com/organizations/plan.
- Create a git bot user (different from your own personal user)
  e.g. https://github.com/join
  and generate a a personal access token, this will be used by Jenkins X to interact with git repositories.
  e.g. https://github.com/settings/tokens/new?scopes=repo,read:user,read:org,user:email,write:repo_hook,delete_repo,admin:repo_hook

- __This bot user needs to have write permission to write to any git repository used by Jenkins X.  This can be done by adding the bot user to the git organisation level or individual repositories as a collaborator__
  Add the new `bot` user to your Git Organisation, for now give it Owner permissions, we will reduce this to member permissions soon.
- Install `terraform` CLI - [see here](https://learn.hashicorp.com/tutorials/terraform/install-cli#install-terraform)
- Install `jx` CLI - [see here](https://github.com/jenkins-x/jx-cli/releases)
- For AWS SSO ensure you have installed `AWSCLI version 2` - [see here](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html). You must then configure it to use Named Profiles - [see here](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)

# Git repositories

We use 2 git repositories:

* **Infrastructure** git repository for the Terraform configuration to setup/upgrade/modify your cloud infrastructure (kubernetes cluster, IAM accounts, IAM roles, buckets etc)
* **Cluster** git repository to contain the `helmfile.yaml` file to define the helm charts to deploy in your cluster

We use separate git repositories since the infrastructure tends to change rarely; whereas the cluster git repository changes alot (every time you add a new quickstart, import a project, release a project etc).

Often different teams look after infrastructure; or you may use tools like Terraform Cloud to process changes to infrastructure & review changes to infrastructure more closely than promotion of applications.

# Getting started

__Note: remember to create the Git repositories below in your Git Organisation rather than your personal Git account else this will lead to issues with ChatOps and automated registering of webhooks__

1. Create and clone your **Infrastructure** git repository from this GitHub Template https://github.com/jx3-gitops-repositories/jx3-terraform-eks/generate
2. Create a **Cluster** git repository from this template https://github.com/jx3-gitops-repositories/jx3-eks-vault/generate
3. Override the variable defaults in the **Infrastructure** repository. (E.g, edit `variables.tf`, set `TF_VAR_` environment variables, or pass the values on the terraform command line.)
 * `cluster_version`: Kubernetes version for the EKS cluster.
 * `region`: AWS region code for the AWS region to create the cluster in.
 * `jx_git_url`: URL of the **Cluster** repository.
 * `jx_bot_username`: The username of the git bot user
4. commit and push any changes to your **Infrastructure** git repository:

```sh
git commit -a -m "fix: configure cluster repository and project"
git push
```

5. Define an environment variable to pass the bot token into Terraform:

```sh
export TF_VAR_jx_bot_token=my-bot-token
```

6. Now, initialise, plan and apply Terraform:

```sh
terraform init
```

```sh
terraform plan
```

```sh
terraform apply
```
Tail the Jenkins X installation logs
```
$(terraform output follow_install_logs)
```
Once finished you can now move into the Jenkins X Developer namespace

```sh
jx ns jx
```

and create or import your applications

```sh
jx project
```

If your application is not yet in a git repository, you are asked for a github.com user and token to push the application to git. This user needs administrative permissions to create repository and hooks. It is likely not the same user as the bot user mentioned above.

## Terraform Inputs

You can modify the following terraform inputs in `main.tf`.

For the full list of terraform inputs [see the documentation for jenkins-x/terraform-aws-eks-jx](https://github.com/jenkins-x/terraform-aws-eks-jx#inputs)

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_name | Name of the Kubernetes cluster to create | `string` | `""` | no |
| cluster\_version | Kubernetes version to use for the EKS cluster. | `string` | n/a | yes |
| force\_destroy | Flag to determine whether storage buckets get forcefully destroyed. If set to false, empty the bucket first in the aws s3 console, else terraform destroy will fail with BucketNotEmpty error | `bool` | `false` | no |
| install\_kuberhealthy | Flag to specify if kuberhealthy operator should be installed | `bool` | `true` | no |
| is\_jx2 | Flag to specify if jx2 related resources need to be created | `bool` | `false` | no |
| jx\_bot\_token | Bot token used to interact with the Jenkins X cluster git repository | `string` | n/a | yes |
| jx\_bot\_username | Bot username used to interact with the Jenkins X cluster git repository | `string` | n/a | yes |
| jx\_git\_url | URL for the Jenins X cluster git repository | `string` | n/a | yes |
| nginx\_chart\_version | nginx chart version | `string` | `"3.12.0"` | no |
| profile | Profile stored in aws config or credentials file | `string` | n/a | yes |
| region | AWS region code for creating resources. | `string` | n/a | yes |
| vault\_user | The AWS IAM Username whose credentials will be used to authenticate the Vault pods against AWS | `string` | `""` | no |

#### Outputs

| Name | Description |
|------|-------------|
| backup\_bucket\_url | The bucket where backups from velero will be stored |
| cert\_manager\_iam\_role | The IAM Role that the Cert Manager pod will assume to authenticate |
| cluster\_autoscaler\_iam\_role | The IAM Role that the Jenkins X UI pod will assume to authenticate |
| cluster\_name | The name of the created cluster |
| cluster\_oidc\_issuer\_url | The Cluster OIDC Issuer URL |
| cm\_cainjector\_iam\_role | The IAM Role that the CM CA Injector pod will assume to authenticate |
| controllerbuild\_iam\_role | The IAM Role that the ControllerBuild pod will assume to authenticate |
| docs | Follow Jenkins X 3.x alpha docs for more information |
| external\_dns\_iam\_role | The IAM Role that the External DNS pod will assume to authenticate |
| follow\_install\_logs | Follow Jenkins X install logs |
| lts\_logs\_bucket | The bucket where logs from builds will be stored |
| lts\_reports\_bucket | The bucket where test reports will be stored |
| lts\_repository\_bucket | The bucket that will serve as artifacts repository |
| tekton\_bot\_iam\_role | The IAM Role that the build pods will assume to authenticate |
| vault\_dynamodb\_table | The Vault DynamoDB table |
| vault\_kms\_unseal | The Vault KMS Key for encryption |
| vault\_unseal\_bucket | The Vault storage bucket |
| vault\_user\_id | The Vault IAM user id |
| vault\_user\_secret | The Vault IAM user secret |

# Cleanup

To remove any cloud resources created here:

* Manually remove the generated load balancer, for example, through the AWS EC2 console "Load Balancers" tab. The load balancer is currently not cleaned up automatically and may cause the following destroy step to hang and finally fail.
* Run:
```sh
terraform destroy
```

# Contributing

When adding new variables please regenerate the markdown table
```sh
terraform-docs markdown table .
```
and replace the Inputs section above

## Formatting

When developing please remember to format codebase before raising a pull request
```sh
terraform fmt -check -diff -recursive
```
