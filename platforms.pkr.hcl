# common upload builder for all virtual environments
build {
  name = "veupload"

  sources = ["source.null.vehost"]

  provisioner "file" {
    name        = "uploadimage"
    source      = "output/${var.target}/packer-kvm.img"
    destination = "/tmp/packer-kvm.img"
  }
}

build {
  name = "proxmox"

  sources = ["source.null.vehost"]

  provisioner "shell" {
    name    = "createvm"
    scripts = ["./scripts/pvecreate.sh"]
    environment_vars = [
      "VMNAME=${lower(var.target)}",
      "VMMEM=${var.proxmox_settings.memory}",
      "VMCORES=${var.proxmox_settings.cpu}",
      "VMNET=${var.proxmox_settings.net}",
      "VMSCSIHW=${var.proxmox_settings.scsihw}",
      "VMSTORE=${var.proxmox_settings.imagestorage}",
      "VMIMGPATH=/tmp/packer-kvm.img",
      "VMOSTYPE=${var.proxmox_settings.ostype}",
      "VMBALLOON=${var.proxmox_settings.balloon}",
      "VMQEMUAGENT=${var.proxmox_settings.qemuagent}",
      "VMCACHE=${var.proxmox_settings.cache}",
      "VMDISCARD=${var.proxmox_settings.discard}",
      "VMDISKFORMAT=${var.proxmox_settings.diskformat}"
    ]
  }
}
