# user build settings
# hint: rename to *.auto.pkrvars.hcl to automatically load this file

image = {
  name             = "debian-12-amd64"
  url              = "https://cloud.debian.org/images/cloud/bookworm/20240211-1654/debian-12-genericcloud-amd64-20240211-1654.qcow2"
  checksum         = "sha512:6856277491c234fa1bc6f250cbd9f0d44f77524479536ecbc0ac536bc07e76322ebb4d42e09605056d6d3879c8eb87db40690a2b5dfe57cb19b0c673fc4c58ca"
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
