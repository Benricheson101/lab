terraform {
  required_providers {
    ansible = {
      source  = "ansible/ansible"
      version = "1.3.0"
    }

    proxmox = {
      source  = "bpg/proxmox"
      version = "0.78.2"
    }
  }

  backend "pg" {}
}

provider "proxmox" {
  endpoint  = var.pve_endpoint
  # api_token = var.pve_token
  username = var.pve_username
  password = var.pve_password
  insecure  = true

  ssh {
    agent    = true
    username = "root"
  }
}

locals {
  vms = {
    for s in flatten([
      proxmox_virtual_environment_container.postgres_ct,
      proxmox_virtual_environment_container.dns_ct,
      proxmox_virtual_environment_container.gateway_ct,
      values(proxmox_virtual_environment_container.media_ct),
    ]) : s.vm_id => { vm_id = s.vm_id, node_name = s.node_name }
  }
}
