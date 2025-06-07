resource "proxmox_virtual_environment_cluster_firewall_security_group" "basic-rules" {
  name = "basic-rules"

  rule {
    type = "in"
    action = "ACCEPT"
    comment = "Allow SSH traffic"
    dport = "22"
    proto = "tcp"
  }

  rule {
    type = "in"
    action = "DROP"
    comment = "Drop all other inbound traffic"
  }
}

resource "proxmox_virtual_environment_cluster_firewall_security_group" "webserver" {
  name = "webserver"

  rule {
    type = "in"
    action = "ACCEPT"
    comment = "Allow HTTPS traffic"
    dport = "443"
    proto = "tcp"
  }

  rule {
    type = "in"
    action = "ACCEPT"
    comment = "Allow HTTP traffic"
    dport = "80"
    proto = "tcp"
  }
}
