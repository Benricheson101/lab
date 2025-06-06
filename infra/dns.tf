resource "proxmox_virtual_environment_vm" "dns_vm" {
  name = "dns-tf"

  node_name = var.pve_node

  stop_on_destroy = false

  initialization {
    user_account {
      username = var.ciuser
      password = var.cipassword
      keys = var.ssh_keys
    }

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  memory {
    dedicated = 1024 * 8
    floating = 1024 * 8
  }

  cpu {
    sockets = 1
    cores = 4
    type = "x86-64-v2-AES"
  }

  serial_device {}

  network_device {
    bridge = "vmbr0"
  }

  agent {
    enabled = true
  }

  disk {
    datastore_id = "local-lvm"
    file_id = proxmox_virtual_environment_download_file.rocky_cloud_image.id
    interface = "virtio0"
    iothread = true
    size = 20
  }
}

resource "ansible_host" "dns_vm" {
  name = flatten(proxmox_virtual_environment_vm.dns_vm.ipv4_addresses)[1]
  groups = ["dns", "rocky"]
  variables = {
    ansible_user = var.ciuser
  }
}
