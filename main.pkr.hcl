packer {
  required_plugins {
    qemu = {
        source  = "github.com/hashicorp/qemu"
        version = "=1.0.9"
    }
    ansible = {
        source  = "github.com/hashicorp/ansible"
        version = "=1.1.0"
    }
  }
}

locals {
    output_directory = "output/${var.target}"
    qemu_info_output = "${local.output_directory}/qemu-info.json"
}

build {
    name = "provision"

    source "source.qemu.base" {
        output_directory = "${local.output_directory}"
    }

    provisioner "ansible" {
        command = "scripts/playbook.sh" # needs to be an executable, scripting is not supported
        host_alias = "default"
        playbook_file = "config/ansible/${var.target}.yaml"
        galaxy_file = "config/ansible/requirements.yaml" # requirements for all playbooks
        extra_arguments = [
            "--scp-extra-args", "'-O'" # https://github.com/hashicorp/packer/issues/11783
        ]
        galaxy_force_install = true # https://github.com/ansible/proposals/issues/181
    }

    post-processors {
        post-processor "shell-local" {
            name = "qemuinfo"
            environment_vars = [
                "IMAGE=${local.output_directory}/packer-base",
                "OUTPUT=${local.qemu_info_output}"
            ]
            inline = ["qemu-img info --output=json \"$IMAGE\" > \"$OUTPUT\""]
        }

        post-processor "shell-local" {
            script = "scripts/qemuinfo.py"
            environment_vars = ["OUTPUT=${local.qemu_info_output}"]
            execute_command  = [
                "/bin/sh",
                "-c",
                "{{.Vars}} $(command -v python3) {{.Script}}"
            ]
        }
    }
}
