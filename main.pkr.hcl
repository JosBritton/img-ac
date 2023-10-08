build {
  name = var.target

  sources = ["source.qemu.kvm"]

  provisioner "shell" {
    inline = ["/usr/bin/cloud-init status --wait"]
  }

  provisioner "ansible" {
    command       = "scripts/playbook.sh"
    playbook_file = "config/ansible/${var.target}.yaml"
    galaxy_file   = "config/ansible/requirements.yaml"
    extra_arguments = [
      "--scp-extra-args", "'-O'" # https://github.com/hashicorp/packer/issues/11783
    ]
    galaxy_force_install = true
  }

  post-processor "checksum" {
    checksum_types      = ["sha512"]
    keep_input_artifact = true
    output              = "output/${var.target}/checksum.sha512sum"
  }
}

# other post-processing in a separate block so that we don't destroy the artifact on error
build {
  name = var.target

  sources = ["source.null.post"]

  post-processors {
    post-processor "shell-local" {
      environment_vars = [
        "IMAGE=output/${var.target}/packer-kvm.img",
        "OUTPUT=output/${var.target}/qemu-info.json"
      ]
      inline = ["json=\"$(qemu-img info --output=json \"$IMAGE\")\" && echo \"$json\" > \"$OUTPUT\""]
    }

    post-processor "shell-local" {
      script           = "scripts/qemuinfo.py"
      environment_vars = ["OUTPUT=output/${var.target}/qemu-info.json"]
      execute_command = [
        "/bin/sh",
        "-c",
        "{{.Vars}} $(command -v python3) {{.Script}}"
      ]
    }
  }
}
