resource "random_pet" "current" {
  prefix    = "tf-jx"
  separator = "-"
  keepers = {
    # Keep the name consistent on executions
    cluster_name = var.cluster_name
  }
}


locals {
  cluster_name      = var.cluster_name != "" ? var.cluster_name : random_pet.current.id
}

provider "aws" {
  region  = var.region
}

// This will create a vpc using the official vpc module
module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "5.9.0"
  name                 = var.vpc_name
  cidr                 = var.vpc_cidr_block
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = var.public_subnets
  private_subnets      = var.private_subnets
  enable_dns_hostnames = true
  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

// This will create the eks cluster using the official eks module
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.20.0"
  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version
  subnet_ids      = (var.cluster_in_private_subnet ? module.vpc.private_subnets : module.vpc.public_subnets)
  vpc_id          = module.vpc.vpc_id
  enable_irsa     = true

  eks_managed_node_groups = {
    eks-jx-node-group = {
      ami_type     = var.ami_type
      desired_size = 3
      min_size     = 2
      max_size     = 5

      instance_types = [var.node_machine_type]
      k8s_labels = {
        "jenkins-x.io/name"       = local.cluster_name
        "jenkins-x.io/part-of"    = "jx-platform"
        "jenkins-x.io/managed-by" = "terraform"
      }
    }
  }

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
}

// The VPC and EKS resources have been created, just install the cloud resources required by jx
module "eks-jx" {
  source = "github.com/jenkins-x/terraform-aws-eks-jx?ref=remove-cluster"
  region = var.region

  use_asm         = var.use_asm
  create_asm_role = var.use_asm
  use_vault       = !var.use_asm

  jx_git_url      = var.jx_git_url
  jx_bot_username = var.jx_bot_username
  jx_bot_token    = var.jx_bot_token

  nginx_chart_version = var.nginx_chart_version

  force_destroy = var.force_destroy

  cluster_name = module.eks.cluster_name
}
