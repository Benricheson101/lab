terraform {
  required_providers {
    ansible = {
      source  = "ansible/ansible"
      version = "1.3.0"
    }

    proxmox = {
      source = "bpg/proxmox"
      version = "0.78.1"
    }
  }

  backend "pg" {}
}

provider "proxmox" {
  endpoint = var.pve_endpoint
  api_token = var.pve_token
  insecure = true

  ssh {
    agent = true
    username = "root"
  }
}
