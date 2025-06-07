resource "proxmox_virtual_environment_download_file" "rocky9_ct" {
  content_type = "vztmpl"
  datastore_id = "local"
  node_name    = "big-pve"
  url          = "https://github.com/Benricheson101/lab/raw/refs/heads/feat/iac/infra/images/rocky9/rocky9-amd64.tar.xz"
}
