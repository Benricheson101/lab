resource "proxmox_virtual_environment_container" "gateway_ct" {
  node_name = var.pve_node

  vm_id = 202
  tags = ["network", "terraform_managed"]

  initialization {
    ip_config {
      ipv4 {
        address = "192.168.5.4/22"
        gateway = var.gateway
      }
    }

    hostname = "gateway"

    user_account {
      keys     = var.ssh_keys
      password = var.cipassword
    }
  }

  memory {
    dedicated = 1 * 1024
    swap      = 0
  }

  cpu {
    cores = 1
  }

  network_interface {
    name = "veth0"
    firewall = true
  }

  disk {
    datastore_id = "local-lvm"
    size         = 4
  }

  operating_system {
    template_file_id = proxmox_virtual_environment_download_file.rocky9_ct.id
    type             = "centos"
  }

  startup {
    order    = 1
    up_delay = 15
  }
}

resource "proxmox_virtual_environment_firewall_rules" "gateway-inbound" {
  vm_id     = proxmox_virtual_environment_container.gateway_ct.vm_id
  node_name = proxmox_virtual_environment_container.gateway_ct.node_name

  rule {
    security_group = proxmox_virtual_environment_cluster_firewall_security_group.webserver.name
  }

  rule {
    security_group = proxmox_virtual_environment_cluster_firewall_security_group.basic-rules.name
  }
}

resource "ansible_host" "gateway_ct" {
  name   = replace(proxmox_virtual_environment_container.gateway_ct.initialization[0].ip_config[0].ipv4[0].address, "//\\d+$/", "")
  groups = ["gateway", "rocky"]
  variables = {
    ansible_user = "root"
  }
}
