#!/usr/bin/env bash
set -e
set -x

source `dirname $0`/configure.sh

terraform init

terraform plan -destroy

terraform destroy -auto-approve
