#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"

pushd infra

export $(sops -d --output-type dotenv .env | xargs)

echo '=> Overriding pg backend'
cat << EOF | tee backend_override.tf
terraform {
  backend "local" {
    path = "./.local-state"
  }
}
EOF

terraform init

echo '=> Creating PostgreSQL container'

terraform apply \
  -target proxmox_virtual_environment_container.postgres_ct \
  -target proxmox_virtual_environment_firewall_rules.postgres-inbound \
  -target ansible_host.postgres_ct

popd

pushd ansible

echo '=> Running Ansible playbook'

ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook site.yml

popd

pushd infra

echo '=> Cleanup and migrate state to new PostgreSQL database'

rm -f backend_override.tf
terraform init -migrate-state

rm -f .local-state .local-state.backup

popd
