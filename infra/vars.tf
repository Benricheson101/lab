variable "ssh_key" {
  default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA7MBT+ivSo5jizQ9oG7h8ul9tm/hWXwLF4HEwfDXrzi benricheson@Bens-MacBook-Pro-2.local"
}

variable "proxmox_host" {
  default = "big-pve"
}

variable "template_name" {
  default = "rocky9-cloudinit"
}

variable "api_url" {}
variable "token_id" {}
variable "token_secret" {}
variable "cipassword" {}
variable "ciuser" {}
