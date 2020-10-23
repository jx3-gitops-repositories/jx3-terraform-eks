#!/usr/bin/env bash
set -e
set -x

# lets configure the terraform module
export TF_VAR_cluster_name=$CLUSTER_NAME
export TF_VAR_jx_git_url=https://${GIT_SERVER_HOST}/${GH_OWNER}/cluster-${CLUSTER_NAME}-dev.git
export TF_VAR_jx_bot_username=$GIT_USERNAME
export TF_VAR_jx_bot_token=$GIT_TOKEN