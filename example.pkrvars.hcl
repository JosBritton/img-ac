# user build settings
# hint: rename to *.auto.pkrvars.hcl to automatically load this file

image = {
  name             = "debian-12-amd64"
  url              = "https://cloud.debian.org/images/cloud/bookworm/20240415-1718/debian-12-genericcloud-amd64-20240415-1718.qcow2"
  checksum         = "sha512:e9ab8bd749543b059a9d0370c11b04a736c403a4a7c9d9575700ce684cf2bee16782145d7c177bb4e609326a2fbb1c3dafd06a3a3261f98a3ed4f9d77c01202b"
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
