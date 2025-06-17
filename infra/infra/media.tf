variable "media_services" {
  default = {
    sonarr = {
      id = 510
      ip = "192.168.5.10/22"
      memory = 1
      cores = 1
      disk = 8
    }
    radarr = {
      id = 511
      ip = "192.168.5.11/22"
      memory = 1
      cores = 1
      disk = 8
    }
    prowlarr = {
      id = 512
      ip = "192.168.5.12/22"
      memory = 1
      cores = 1
      disk = 16
    }
    qbittorrent = {
      id = 513
      ip = "192.168.5.13/22"
      memory = 2
      cores = 2
      disk = 16
    }
    testing = {
      id = 514
      ip = "192.168.5.14/22"
      memory = 2
      cores = 2
      disk = 16
    }
    plex = {
      id = 515
      ip = "192.168.5.15/22"
      memory = 8
      cores = 4
      disk = 32
    }
  }
}

resource "proxmox_virtual_environment_container" "media_ct" {
  node_name = var.pve_node

  for_each = var.media_services

  vm_id = each.value.id
  tags = ["media", "terraform_managed"]

  initialization {
    ip_config {
      ipv4 {
        address = each.value.ip
        gateway = var.gateway
      }
    }

    hostname = each.key

    user_account {
      keys     = var.ssh_keys
      password = var.cipassword
    }
  }

  memory {
    dedicated = each.value.memory * 1024
    swap      = 0
  }

  cpu {
    cores = each.value.cores
  }

  network_interface {
    name = "veth0"
    firewall = true
  }

  disk {
    datastore_id = "local-lvm"
    size         = each.value.disk
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

resource "proxmox_virtual_environment_firewall_rules" "media-inbound" {
  for_each = proxmox_virtual_environment_container.media_ct

  vm_id = each.value.vm_id
  node_name = each.value.node_name

  rule {
    security_group = proxmox_virtual_environment_cluster_firewall_security_group.webserver.name
  }

  rule {
    security_group = proxmox_virtual_environment_cluster_firewall_security_group.basic-rules.name
  }
}

resource "ansible_host" "media_ct" {
  for_each = proxmox_virtual_environment_container.media_ct

  name   = replace(each.value.initialization[0].ip_config[0].ipv4[0].address, "//\\d+$/", "")
  groups = ["media", "rocky", each.key]
  variables = {
    ansible_user = "root"
  }
}
