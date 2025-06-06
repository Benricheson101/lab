resource "proxmox_virtual_environment_download_file" "rocky_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name = "big-pve"
  url = "https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2"
  file_name = "rocky_cloud_image.img"
}
