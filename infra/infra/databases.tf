resource "proxmox_virtual_environment_container" "postgres_ct" {
  node_name = var.pve_node

  vm_id = 201
  tags = ["databases", "terraform_managed"]

  initialization {
    ip_config {
      ipv4 {
        address = "192.168.6.32/22"
        gateway = var.gateway
      }
    }

    hostname = "postgres-tf"

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
    name     = "veth0"
    firewall = true
  }

  disk {
    datastore_id = "local-lvm"
    size         = 64
  }

  operating_system {
    template_file_id = proxmox_virtual_environment_download_file.rocky9_ct.id
    type             = "centos"
  }

  startup {
    order    = 2
    up_delay = 30
  }
}

resource "proxmox_virtual_environment_firewall_rules" "postgres-inbound" {
  vm_id     = proxmox_virtual_environment_container.postgres_ct.vm_id
  node_name = proxmox_virtual_environment_container.postgres_ct.node_name

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow postgres traffic on port 5432/tcp"
    dport   = "5432"
    source = var.lan
    proto = "tcp"
  }

  rule {
    security_group = proxmox_virtual_environment_cluster_firewall_security_group.basic-rules.name
  }
}

resource "ansible_host" "postgres_ct" {
  name   = replace(proxmox_virtual_environment_container.postgres_ct.initialization[0].ip_config[0].ipv4[0].address, "//\\d+$/", "")
  groups = ["postgres", "database", "rocky"]
  variables = {
    ansible_user = "root"
  }
}
