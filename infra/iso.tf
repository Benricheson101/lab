resource "proxmox_virtual_environment_download_file" "rocky_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "big-pve"
  url          = "https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2"
  file_name    = "rocky_cloud_image.img"
}

resource "proxmox_virtual_environment_download_file" "rocky9_ct" {
  content_type = "vztmpl"
  datastore_id = "local"
  node_name    = "big-pve"
  url          = "https://images.linuxcontainers.org/images/rockylinux/9/amd64/cloud/20250606_02:06/rootfs.tar.xz"
  # url = "https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-Base-9.6-20250531.0.x86_64.tar.xz"
}

resource "proxmox_virtual_environment_download_file" "rocky9_ct_2" {
  content_type = "vztmpl"
  datastore_id = "local"
  node_name    = "big-pve"
  url          = "https://github.com/Benricheson101/lab/raw/refs/heads/feat/iac/infra/images/rocky9/rocky9-amd64.tar.xz"
  # url = "https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-Base-9.6-20250531.0.x86_64.tar.xz"
}

# resource "proxmox_virtual_environment_download_file" "alma9_ct" {
#   content_type = "vztmpl"
#   datastore_id = "local"
#   node_name    = "big-pve"
#   url          = "https://images.linuxcontainers.org/images/almalinux/9/amd64/cloud/20250606_23%3A08/rootfs.tar.xz"
#   file_name = "alma-9.6-amd-64-rootfs.tar.xz"
#   # url = "https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-Base-9.6-20250531.0.x86_64.tar.xz"
# }
