#!/usr/bin/env bash
set -e
set -x

terraform init

terraform plan

terraform apply -auto-approve -input=false