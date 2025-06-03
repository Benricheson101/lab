terraform {
  required_providers {
    ansible = {
      source  = "ansible/ansible"
      version = "1.3.0"
    }

    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc9"
    }
  }

  backend "pg" {}
}

provider "proxmox" {
  pm_api_url          = var.api_url
  pm_api_token_id     = var.token_id
  pm_api_token_secret = var.token_secret
  pm_tls_insecure     = true
}

resource "ansible_host" "media_vm" {
  name = proxmox_vm_qemu.media_vm.default_ipv4_address
  groups = ["gpu", "rocky"]
}

# vim: ft=hcl
