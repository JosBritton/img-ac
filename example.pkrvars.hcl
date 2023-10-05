# user build settings
# hint: rename to *.auto.pkrvars.hcl to automatically load this file

image_url = "https://cloud.debian.org/images/cloud/bookworm/20230910-1499/debian-12-genericcloud-amd64-20230910-1499.qcow2"
image_checksum = "sha512:42f3565ef632bea438b55acffb24a87400c4e285c50a5b79083da1c2ba6eb02e381adb3b45fec387f2852b64170a451be46bcc3b50c0d79a229daaf641b96453"

proxmox_settings = {
    "memory" = "4096"
    "cpu" = "8"
    "net" = "virtio,bridge=vmbr0"
    "scsihw" = "virtio-scsi-single"
    "imagestorage" = "vmstore"
    "ostype" = "l26"
    "balloon" = "0"
    "qemuagent" = "enabled=1,fstrim_cloned_disks=1"
    "cache" = "none"
    "discard" = "on"
    "diskformat" = "raw"
}

local_vm_settings = {
    "cache" = "none"
    "net_device" = "virtio-net"
    "disk_interface" = "virtio-scsi"
    "memory" = "8192"
    "output_format" = "qcow2"
    "virtual_disk_size" = "4G"
}
