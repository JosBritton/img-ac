variable "target" {
    type = string
    validation {
        # ansible group names don't allow dashes
        # qemu wants valid hostnames (which don't allow underscores)
        condition = can(regex("^[A-z0-9]+$", var.target))
        error_message = "Group names may only be alphanumeric."
    }
}

variable "ssh_public_key" {
    type = string
    default = null # optional if build_only=1
}

variable "ssh_private_key_file_path" {
    type = string
    default = null # see above comment
}

variable "local_vm_settings" {
    type = object({
        output_format = string
        cache = string
        net_device = string
        disk_interface = string
        memory = string
        virtual_disk_size = string
    })
    default = {
        output_format = "qcow2"
        cache = "none"
        net_device = "virtio-net"
        disk_interface = "virtio-scsi"
        memory = "512"
        virtual_disk_size = "16G" # must be larger than the base disk image virtual disk size
                                    # bad things will happen during provisioning if your install
                                    # becomes larger than this value (e.g. downloading packages)
    }
}

variable "proxmox_settings" {
    type = object({
        memory = string
        cpu = string
        net = string
        scsihw = string
        imagestorage = string
        ostype = string
        balloon = string
        qemuagent = string
        cache = string
        discard = string
        diskformat = string
    })
    default = {
        memory = "2048"
        cpu = "1"
        net = "virtio,bridge=vmbr0"
        scsihw = "virtio-scsi-single"
        imagestorage = "local-lvm"
        ostype = "l26"
        balloon = "0"
        qemuagent = "enabled=1,fstrim_cloned_disks=1"
        cache = "none"
        discard = "on"
        diskformat = "raw"
    }
}

variable "image_checksum" {
    type = string
}

variable "image_url" {
    type = string
}
