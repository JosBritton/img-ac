locals {
    iso_checksum = "sha512:42f3565ef632bea438b55acffb24a87400c4e285c50a5b79083da1c2ba6eb02e381adb3b45fec387f2852b64170a451be46bcc3b50c0d79a229daaf641b96453"
    iso_url = "https://cloud.debian.org/images/cloud/bookworm/20230910-1499/debian-12-genericcloud-amd64-20230910-1499.qcow2"
    instance-id = uuidv5("url", "${local.iso_url}")
}

source "qemu" "base" {
    use_backing_file = false
    headless = true
    disk_image = true

    disk_size = var.local_vm_settings.virtual_disk_size
    disk_cache = var.local_vm_settings.cache
    format = var.local_vm_settings.output_format
    memory = var.local_vm_settings.memory
    net_device = var.local_vm_settings.net_device
    disk_interface = var.local_vm_settings.disk_interface
    http_content = {
        "/user-data" = join("\n", ["#cloud-config", yamlencode({
            "users" = [
                {
                    "name": "root"
                    "ssh_authorized_keys": [
                        var.ssh_public_key
                    ]
                }
            ]
        })])
        "/meta-data" = yamlencode({
            instance-id = local.instance-id
        })
    }
    qemuargs = [
        ["-smbios", "type=1,serial=ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/"]
    ]
    ssh_private_key_file = var.ssh_private_key_file_path
    ssh_username = "root"

    iso_url = var.image_url
    iso_checksum = var.image_checksum
}
