variable "image" {
  type = object({
    url              = string
    checksum         = string
    shutdown_command = string
    user             = string
  })
  description = "The details of the base image to use for the VM."
  default = {
    name             = "debian-12-amd64"
    url              = "https://cloud.debian.org/images/cloud/bookworm/20231004-1523/debian-12-genericcloud-amd64-20231004-1523.qcow2"
    checksum         = "sha512:b594a146d0c85aa138b7fd4ba27cdf4c56fcceef2f90d6f4e1553d35c7faeab566df885ccaa2e48b2c9edf1d1926f0b997406f34729708069c6fad9ee1c73397"
    shutdown_command = "sudo shutdown -P now"
    user             = "packer"
  }
}

variable "target" {
  type        = string
  description = <<-EOF
  The target group to provision and unique name of the VM to create.
  This is passed by the Makefile.
  EOF
  validation {
    condition     = can(regex("^[A-z0-9]+$", var.target))
    error_message = <<-EOF
    Group names may only be alphanumeric. Ansible group names don't
    allow dashes, and qemu wants valid hostnames (which don't allow underscores).
    EOF
  }
}

variable "local_vm_settings" {
  description = "Settings for the local VM."
  type = object({
    output_format     = string
    cache             = string
    net_device        = string
    disk_interface    = string
    memory            = string
    virtual_disk_size = string
  })
  default = {
    output_format     = "qcow2"
    cache             = "none"
    net_device        = "virtio-net"
    disk_interface    = "virtio-scsi"
    memory            = "512"
    virtual_disk_size = "16G" # must be larger than the base disk image virtual disk size
    # bad things will happen during provisioning if your install
    # becomes larger than this value (e.g. downloading packages)
  }
}

variable "proxmox_settings" {
  description = "Settings for the Proxmox VM."
  type = object({
    memory       = string
    cpu          = string
    net          = string
    scsihw       = string
    imagestorage = string
    ostype       = string
    balloon      = string
    qemuagent    = string
    cache        = string
    discard      = string
    diskformat   = string
  })
  default = {
    memory       = "2048"
    cpu          = "1"
    net          = "virtio,bridge=vmbr0"
    scsihw       = "virtio-scsi-single"
    imagestorage = "local-lvm"
    ostype       = "l26"
    balloon      = "0"
    qemuagent    = "enabled=1,fstrim_cloned_disks=1"
    cache        = "none"
    discard      = "on"
    diskformat   = "raw"
  }
}
