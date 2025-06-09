locals {
  vms = {
    for s in flatten([
      proxmox_virtual_environment_container.postgres_ct,
      proxmox_virtual_environment_container.dns_ct,
      proxmox_virtual_environment_container.gateway_ct,
      values(proxmox_virtual_environment_container.media_ct),
    ]) : s.vm_id => { vm_id = s.vm_id, node_name = s.node_name }
  }
}
