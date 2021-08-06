provider "aws" {
  region  = var.region
  profile = var.profile
}

module "eks-jx" {
  source               = "jenkins-x/eks-jx/aws?ref=v1.15.12"
  version              = "1.15.38"
  cluster_version      = var.cluster_version
  region               = var.region
  vault_user           = var.vault_user
  is_jx2               = false
  jx_git_url           = var.jx_git_url
  jx_bot_username      = var.jx_bot_username
  jx_bot_token         = var.jx_bot_token
  force_destroy        = var.force_destroy
  nginx_chart_version  = var.nginx_chart_version
  install_kuberhealthy = var.install_kuberhealthy
}
