#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"
pushd infra

export $(sops -d --output-type dotenv .env | xargs)
terraform apply

popd
pushd ansible

ansible-playbook site.yml

popd
