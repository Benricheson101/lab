resource "proxmox_virtual_environment_container" "tailscale_ct" {
  node_name = var.pve_node

  vm_id = 203
  tags = ["network", "terraform_managed"]

  initialization {
    ip_config {
      ipv4 {
        address = "192.168.5.5/22"
        gateway = var.gateway
      }
    }

    ip_config {
      ipv4 {
        address = "10.3.62.2/24"
        gateway = "10.3.62.1"
      }
    }

    hostname = "tailscale"

    user_account {
      keys     = var.ssh_keys
      password = var.cipassword
    }
  }

  memory {
    dedicated = 4 * 1024
    swap      = 0
  }

  cpu {
    cores = 4
  }

  network_interface {
    name = "veth0"
    firewall = false
  }

  network_interface {
    name = "vmbr1"
    bridge = "vmbr1"
    firewall = false
  }

  disk {
    datastore_id = "local-lvm"
    size         = 8
  }

  operating_system {
    template_file_id = proxmox_virtual_environment_download_file.rocky9_ct.id
    type             = "centos"
  }

  device_passthrough {
    // is this okay to do lol
    path = "/dev/net/tun"
  }

  startup {
    order    = 1
    up_delay = 15
  }
}

resource "proxmox_virtual_environment_firewall_rules" "tailscale-inbound" {
  vm_id     = proxmox_virtual_environment_container.tailscale_ct.vm_id
  node_name = proxmox_virtual_environment_container.tailscale_ct.node_name

  depends_on = [
    proxmox_virtual_environment_container.tailscale_ct,
    proxmox_virtual_environment_cluster_firewall_security_group.basic-rules,
  ]

  rule {
    security_group = proxmox_virtual_environment_cluster_firewall_security_group.basic-rules.name
  }
}

resource "ansible_host" "tailscale_ct" {
  name   = replace(proxmox_virtual_environment_container.tailscale_ct.initialization[0].ip_config[0].ipv4[0].address, "//\\d+$/", "")
  groups = ["tailscale", "rocky"]
  variables = {
    ansible_user = "root"
  }
}
