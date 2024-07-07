# user build settings
# hint: rename to *.auto.pkrvars.hcl to automatically load this file

image = {
  name             = "debian-12-amd64"
  url              = "https://cloud.debian.org/images/cloud/bookworm/20240507-1740/debian-12-genericcloud-amd64-20240507-1740.qcow2"
  checksum         = "sha512:e7efdc6e0ae643b05c6d53e10efbfd4454a769e13ddd69b5fabaa3e00c0ec431e6d6022530ecc922d944875409f4db66f69f1c134f64098959ab43de321d67c7"
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
