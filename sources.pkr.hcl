source "null" "post" {
  communicator = "none"
}

source "qemu" "kvm" {
  use_backing_file = false
  headless         = true
  disk_image       = true
  ssh_timeout      = "120s"
  disk_compression = true

  output_directory     = "output/${var.target}"
  ssh_private_key_file = "/tmp/packer/id_${var.target}"
  vm_name              = "packer-kvm.img"

  # when building in parallel, a global lock is used to prevent race conditions when downloading
  iso_url      = var.image.url
  iso_checksum = var.image.checksum

  ssh_username = var.image.user
  ssh_password = null

  disk_size      = var.local_vm_settings.virtual_disk_size
  disk_cache     = var.local_vm_settings.cache
  format         = var.local_vm_settings.output_format
  memory         = var.local_vm_settings.memory
  net_device     = var.local_vm_settings.net_device
  disk_interface = var.local_vm_settings.disk_interface

  # to my knowledge, this cloud-init config is distro agnostic
  http_content = {
    "/user-data" = join("\n", ["#cloud-config", yamlencode({
      "users" = [
        {
          "name" : var.image.user
          "ssh_authorized_keys" : [
            file("/tmp/packer/id_${var.target}.pub")
          ]
        }
      ]
    })])
    "/meta-data" = yamlencode({
      instance-id = uuidv5("url", var.image.url)
    })
  }
  qemuargs = [
    ["-smbios", "type=1,serial=ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/"]
  ]
}
