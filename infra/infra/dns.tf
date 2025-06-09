resource "proxmox_virtual_environment_container" "dns_ct" {
  node_name = var.pve_node

  vm_id = 200
  tags = ["network", "terraform_managed"]

  initialization {
    ip_config {
      ipv4 {
        address = "192.168.5.3/22"
        gateway = var.gateway
      }
    }

    hostname = "dns-tf"

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
    firewall = true
  }

  disk {
    datastore_id = "local-lvm"
    size         = 8
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

resource "proxmox_virtual_environment_firewall_rules" "dns-inbound" {
  vm_id     = proxmox_virtual_environment_container.dns_ct.vm_id
  node_name = proxmox_virtual_environment_container.dns_ct.node_name

  depends_on = [
    proxmox_virtual_environment_container.dns_ct,
    proxmox_virtual_environment_cluster_firewall_security_group.basic-rules,
  ]

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow DNS traffic on port 53/udp"
    dport   = "53"
    proto   = "udp"
  }

  rule {
    security_group = proxmox_virtual_environment_cluster_firewall_security_group.basic-rules.name
  }
}

resource "ansible_host" "dns_ct" {
  name   = replace(proxmox_virtual_environment_container.dns_ct.initialization[0].ip_config[0].ipv4[0].address, "//\\d+$/", "")
  groups = ["dns", "rocky"]
  variables = {
    ansible_user = "root"
  }
}
