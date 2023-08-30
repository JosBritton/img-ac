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

variable "dir" {
    type = string
}

local "ansible_extra_arguments" {
    expression = [
        #"-vvvv",
        "--scp-extra-args", "'-O'" # https://github.com/hashicorp/packer/issues/11783
    ]
}

build {
    source "source.qemu.base" {
        output_directory = "out/${var.dir}"
    }

    # playbook targets host with associated group name
    provisioner "ansible" {
        command = "ansible/playbook.sh"
        host_alias = "default"
        groups = ["${var.dir}"]
        playbook_file = "ansible/site.yml"
        galaxy_file = "ansible/requirements.yml"
        extra_arguments = "${local.ansible_extra_arguments}"
        use_proxy = false
        galaxy_force_install = true # https://github.com/ansible/proposals/issues/181
    }

    provisioner "shell" {
        # reclaim space for thin-provisioned images
        inline = ["dd if=/dev/zero of=/EMPTY bs=1M || true", "rm -f /EMPTY", "sync"]
    }
}
