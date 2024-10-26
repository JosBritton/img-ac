variable "image" {
  type = object({
    name             = string
    base             = string
    shutdown_command = string
    user             = string
  })
  description = "The details of the base image to use for the VM."
  default = {
    name             = "packer-template"
    base             = "debian-12-genericcloud-amd64"
    shutdown_command = "sudo shutdown now"
    user             = "packer"
  }
}

variable "image_repository" {
  type = map(object({
    url    = string
    digest = string
  }))
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
