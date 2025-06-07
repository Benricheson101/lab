resource "proxmox_virtual_environment_cluster_firewall_security_group" "basic-rules" {
  name = "basic-rules"

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow SSH traffic"
    dport   = "22"
    proto   = "tcp"
  }

  rule {
    type    = "in"
    action  = "DROP"
    comment = "Drop all other inbound traffic"
  }
}

resource "proxmox_virtual_environment_cluster_firewall_security_group" "webserver" {
  name = "webserver"

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
}

resource "proxmox_virtual_environment_firewall_options" "fw" {
  for_each = {
    for s in [
      proxmox_virtual_environment_container.postgres_ct,
      proxmox_virtual_environment_container.dns_ct,
    ] : s.vm_id => { vm_id = s.vm_id, node_name = s.node_name }
  }

  node_name = each.value.node_name
  vm_id     = each.value.vm_id

  enabled       = true
  input_policy  = "DROP"
  output_policy = "ACCEPT"
}

