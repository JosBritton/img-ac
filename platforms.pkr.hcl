source "null" "ssh" {}

# common upload builder for all virtual environments
build {
  name = "veupload"

  dynamic "source" {
    labels   = ["null.ssh"]
    for_each = var.vehost_sources
    content {
      name                 = source.value.name
      ssh_host             = source.value.ssh_host
      ssh_username         = source.value.ssh_username
      ssh_private_key_file = source.value.ssh_private_key_file
    }
  }

  provisioner "file" {
    name        = "uploadimage"
    source      = "output/${var.target}/packer-kvm.img"
    destination = "/tmp/packer-kvm.img"
  }
}

build {
  name = "proxmox"

  dynamic "source" {
    labels   = ["null.ssh"]
    for_each = var.vehost_sources
    content {
      name                 = source.value.name
      ssh_host             = source.value.ssh_host
      ssh_username         = source.value.ssh_username
      ssh_private_key_file = source.value.ssh_private_key_file
    }
  }

  provisioner "shell" {
    name    = "createvm"
    scripts = ["./scripts/pvecreate.sh"]
    environment_vars = [
      "VMNAME=${lower(var.target)}",
      "VMID=${var.proxmox_settings[source.name].vmid}",
      "VMMEM=${var.proxmox_settings[source.name].memory}",
      "VMCORES=${var.proxmox_settings[source.name].cpu}",
      "VMNET=${var.proxmox_settings[source.name].net}",
      "VMSCSIHW=${var.proxmox_settings[source.name].scsihw}",
      "VMSTORE=${var.proxmox_settings[source.name].imagestorage}",
      "VMIMGPATH=/tmp/packer-kvm.img",
      "VMOSTYPE=${var.proxmox_settings[source.name].ostype}",
      "VMBALLOON=${var.proxmox_settings[source.name].balloon}",
      "VMQEMUAGENT=${var.proxmox_settings[source.name].qemuagent}",
      "VMCACHE=${var.proxmox_settings[source.name].cache}",
      "VMDISCARD=${var.proxmox_settings[source.name].discard}",
      "VMDISKFORMAT=${var.proxmox_settings[source.name].diskformat}"
    ]
  }
}
