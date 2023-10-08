# user build settings
# hint: rename to *.auto.pkrvars.hcl to automatically load this file

image = {
  name             = "debian-12-amd64"
  url              = "https://cloud.debian.org/images/cloud/bookworm/20231004-1523/debian-12-genericcloud-amd64-20231004-1523.qcow2"
  checksum         = "sha512:b594a146d0c85aa138b7fd4ba27cdf4c56fcceef2f90d6f4e1553d35c7faeab566df885ccaa2e48b2c9edf1d1926f0b997406f34729708069c6fad9ee1c73397"
  shutdown_command = "sudo shutdown -P now"
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

proxmox_settings = {
  "memory"       = "2048"
  "cpu"          = "1"
  "net"          = "virtio,bridge=vmbr0"
  "scsihw"       = "virtio-scsi-single"
  "imagestorage" = "local-lvm"
  "ostype"       = "l26"
  "balloon"      = "0"
  "qemuagent"    = "enabled=1,fstrim_cloned_disks=1"
  "cache"        = "none"
  "discard"      = "on"
  "diskformat"   = "qcow2"
}
