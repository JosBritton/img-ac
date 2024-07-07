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
    url              = "https://cloud.debian.org/images/cloud/bookworm/20240211-1654/debian-12-genericcloud-amd64-20240211-1654.qcow2"
    checksum         = "sha512:6856277491c234fa1bc6f250cbd9f0d44f77524479536ecbc0ac536bc07e76322ebb4d42e09605056d6d3879c8eb87db40690a2b5dfe57cb19b0c673fc4c58ca"
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

variable "vehost_sources" {
  type = list(object({
    name                 = string
    ssh_host             = string
    ssh_username         = string
    ssh_private_key_file = string
  }))
  default = null
}

variable "proxmox_settings" {
  type = map(object({
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
    vmid         = string
  }))
  default = null
}
