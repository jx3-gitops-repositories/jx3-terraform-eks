provider "aws" {
  region  = var.region
  profile = var.profile
}

module "eks-jx" {
  source                               = "github.com/jenkins-x/terraform-aws-eks-jx?ref=v2.0.1"
  cluster_version                      = var.cluster_version
  cluster_name                         = var.cluster_name
  region                               = var.region
  profile                              = var.profile
  jx_git_url                           = var.jx_git_url
  jx_bot_username                      = var.jx_bot_username
  jx_bot_token                         = var.jx_bot_token
  force_destroy                        = var.force_destroy
  nginx_chart_version                  = var.nginx_chart_version
  install_kuberhealthy                 = var.install_kuberhealthy
  enable_worker_group                  = false
  enable_worker_groups_launch_template = true
  create_addon_role                    = true
  enable_ebs_addon                     = true
}
