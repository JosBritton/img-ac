# user build settings
# hint: rename to *.auto.pkrvars.hcl to automatically load this file

image = {
  name             = "packer-templte"
  base             = "debian-12-genericcloud-amd64" # see: `images.auto.pkrvars.hcl`
  shutdown_command = "sudo shutdown now"
  user             = "packer"
}

local_vm_settings = {
  "cache"             = "none"
  "net_device"        = "virtio-net"
  "disk_interface"    = "virtio-scsi"
  "memory"            = "512"
  "output_format"     = "qcow2"
  "virtual_disk_size" = "16G"
}

vehost_sources = [
  {
    name                 = "pve1"
    ssh_host             = "pve1.example.org"
    ssh_username         = "root"
    ssh_private_key_file = "~/.ssh/id_ed25519"
  },
  {
    name                 = "pve2"
    ssh_host             = "pve2.example.org"
    ssh_username         = "root"
    ssh_private_key_file = "~/.ssh/id_ed25519"
  }
]

proxmox_settings = {
  pve1 = {
    memory       = "4096"
    cpu          = 8
    net          = "virtio,bridge=vmbr0"
    scsihw       = "virtio-scsi-single"
    imagestorage = "rpool2"
    ostype       = "l26"
    balloon      = 0
    qemuagent    = "enabled=1,fstrim_cloned_disks=1"
    cache        = "none"
    discard      = "on"
    diskformat   = "raw"
  }
  pve2 = {
    memory       = "4096"
    cpu          = 4
    net          = "virtio,bridge=vmbr0"
    scsihw       = "virtio-scsi-single"
    imagestorage = "rpool2"
    ostype       = "l26"
    balloon      = 0
    qemuagent    = "enabled=1,fstrim_cloned_disks=1"
    cache        = "none"
    discard      = "on"
    diskformat   = "raw"
  }
}
