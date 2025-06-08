resource "proxmox_virtual_environment_container" "gateway_ct" {
  node_name = var.pve_node

  vm_id = 202

  initialization {
    ip_config {
      ipv4 {
        address = "192.168.5.4/22"
        gateway = var.gateway
      }
    }

    hostname = "gateway-tf"

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
    order    = 3
    up_delay = 15
  }
}

resource "proxmox_virtual_environment_firewall_rules" "gateway-inbound" {
  vm_id     = proxmox_virtual_environment_container.gateway_ct.vm_id
  node_name = proxmox_virtual_environment_container.gateway_ct.node_name

  depends_on = [
    proxmox_virtual_environment_container.gateway_ct,
    proxmox_virtual_environment_cluster_firewall_security_group.basic-rules,
  ]

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow HTTPS traffic"
    dport   = "443"
    proto   = "tcp"
  }

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow HTTP traffic"
    dport   = "80"
    proto   = "tcp"
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
