resource "proxmox_virtual_environment_container" "plex_ct" {
  node_name = var.pve_node

  vm_id = 515
  tags = ["media", "terraform_managed"]

  initialization {
    ip_config {
      ipv4 {
        address = "192.168.5.15/22"
        gateway = var.gateway
      }
    }

    hostname = "plex"

    user_account {
      keys     = var.ssh_keys
      password = var.cipassword
    }
  }

  memory {
    dedicated = 8 * 1024
    swap      = 0
  }

  cpu {
    cores = 4
  }

  network_interface {
    name = "veth0"
    firewall = true
  }

  disk {
    datastore_id = "local-lvm"
    size         = 32
  }

  operating_system {
    template_file_id = proxmox_virtual_environment_download_file.rocky9_ct.id
    type             = "centos"
  }

  startup {
    order    = 3
    up_delay = 15
  }
}

resource "proxmox_virtual_environment_firewall_rules" "plex-inbound" {
  vm_id     = proxmox_virtual_environment_container.plex_ct.vm_id
  node_name = proxmox_virtual_environment_container.plex_ct.node_name

  rule {
    type = "in"
    action = "ACCEPT"
    dport = "32400"
    proto = "tcp"
  }

  rule {
    security_group = proxmox_virtual_environment_cluster_firewall_security_group.basic-rules.name
  }
}

resource "ansible_host" "plex_ct" {
  name   = replace(proxmox_virtual_environment_container.plex_ct.initialization[0].ip_config[0].ipv4[0].address, "//\\d+$/", "")
  groups = ["plex", "rocky"]
  variables = {
    ansible_user = "root"
  }
}
