variable "ssh_public_key" {
    type = string
}

variable "ssh_private_key_file_path" {
    type = string
}

locals {
    iso_checksum = "sha512:5baa9145e87b21b4523d07a02b1374e30ab9cef301b6e92f519d6411a9ce996d7817b746005854343cdcb17cc2488b9f07727b8a64d17e440bd7cd18eac7f4ef"
    iso_url = "https://cloud.debian.org/images/cloud/bookworm/20230802-1460/debian-12-genericcloud-amd64-20230802-1460.qcow2"
    instance-id = uuidv5("url", "${local.iso_url}")
}

source "qemu" "base" {
    headless = true
    skip_resize_disk = true
    disk_cache = "none"
    disk_image = true
    format = "qcow2" # OUTPUT format
    use_backing_file = false # whether to only save delta IF format=qcow2
    memory = 512
    net_device = "virtio-net"
    disk_interface = "virtio-scsi"
    http_content = {
        "/user-data" = join("\n", ["#cloud-config", yamlencode({
            "users" = [
                {
                    "name": "root"
                    "ssh_authorized_keys": [
                        "${var.ssh_public_key}"
                    ]
                }
            ]
        })])
        "/meta-data" = yamlencode({
            instance-id = "${local.instance-id}"
        })
    }
    qemuargs = [
        ["-smbios", "type=1,serial=ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/"]
    ]
    ssh_private_key_file = "${var.ssh_private_key_file_path}"
    ssh_username = "root"
    iso_checksum = "${local.iso_checksum}"
    iso_url = "${local.iso_url}"
}
