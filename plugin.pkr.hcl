packer {
  required_plugins {
    qemu = {
      # https://developer.hashicorp.com/packer/integrations/hashicorp/qemu/latest/components/builder/qemu
      source  = "github.com/hashicorp/qemu"
      version = "=1.0.10"
    }
    ansible = {
      # https://developer.hashicorp.com/packer/integrations/hashicorp/ansible/latest/components/provisioner/ansible
      source  = "github.com/hashicorp/ansible"
      version = "=1.1.1"
    }
  }
}
