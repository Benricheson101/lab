resource "proxmox_vm_qemu" "dns_vm" {
  name        = "dns-tf"
  vmid        = 502
  target_node = var.proxmox_host
  clone       = var.template_name
  full_clone  = "true"
  agent       = 1
  os_type     = "cloud-init"
  scsihw      = "virtio-scsi-pci"
  boot        = "order=scsi0"

  ciuser     = var.ciuser
  cipassword = var.cipassword
  sshkeys    = var.ssh_key
  ipconfig0  = "ip=dhcp"

  memory = 1024 * 4

  cpu {
    cores   = 4
    sockets = 1
    type    = "x86-64-v2-AES"
  }

  disk {
    type    = "cloudinit"
    slot    = "ide2"
    storage = "local-lvm"
  }

  disk {
    format = "raw"
    slot    = "scsi0"
    size    = "64G"
    type    = "disk"
    storage = "local-lvm"
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  serial {
    id   = 0
    type = "socket"
  }
}

resource "ansible_host" "dns_vm" {
  name = proxmox_vm_qemu.dns_vm.default_ipv4_address
  groups = ["dns", "rocky"]
}
