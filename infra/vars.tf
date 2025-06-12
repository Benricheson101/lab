variable "ssh_keys" {
  type    = list(string)
  default = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA7MBT+ivSo5jizQ9oG7h8ul9tm/hWXwLF4HEwfDXrzi benricheson@Bens-MacBook-Pro-2.local"]
}

variable "pve_node" {
  default = "big-pve"
}

variable "gateway" {
  default = "192.168.4.1"
}

variable "lan" {
  default = "192.168.4.0/22"
}

variable "pve_endpoint" {}
variable "pve_token" {}
variable "cipassword" {}
variable "ciuser" {}
variable "pve_username" {}
variable "pve_password" {}
