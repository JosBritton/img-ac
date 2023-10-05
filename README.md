# IMG-AC

(Images as code)

Image creation harness for Qemu based virtual environments.

Cloud-init will handle the following (and is therefore, not managed here):

- DNS
- IP assignment
- Hostname
- Password
- Authorized keys
- Timezone
- NTP
- Additional users

## Basic usage

1. Ensure you have the required base dependencies:

   - [`python3`](https://www.python.org/downloads/)
   - [`packer`](https://developer.hashicorp.com/packer/downloads?product_intent=packer)
   - [`GNU make`](https://www.gnu.org/software/make/)
   - [`Qemu`](https://www.qemu.org/)

2. (optional) Create `./vehost.pkr.hcl`:

   Create a valid `null` source with a valid SSH communicator configuration and the label `vehost`.

   This can be any remote machine that you would like to transfer the image to, although the purpose is for a virtual machine host.

   See [docs](https://developer.hashicorp.com/packer/docs/communicators/ssh) for information on the Packer SSH communicator.

   ```
   source "null" "vehost" {
       ssh_host = "127.0.0.1"
       ssh_username = "foo"
       ssh_password = "bar" # if you want to use SSH keys, use `ssh_private_key_file` instead
   }
   ```

3. Use `make <all|BUILD_NAME>` to build, it injects a newly generated ssh key into the build process via the variables `ssh_public_key` and `ssh_private_key_file_path`, therefore you may skip this and specify your own key using the same variables.

   ```
   make <all|BUILD_NAME>
   ```

   If you would like to skip automatically trying to upload to a virtual environment after image creation, set `VE_UPLOAD=0` to your `make` command or set it as an environment variable.

   ```
   make VE_UPLOAD=0 <all|BUILD_NAME>
   ```

### Uploading previously built images to a virtual environment

1. Ensure the image is built and present at `out/<target>/packer-base`
2. Upload the image with `make`. `IMG-AC` will go through every build name present in the `makefile` and try to upload to your `vehost` source.
   ```
   make upload
   ```

### Update python virtual environment

```
make -B .venv
```

## Configuration

- `*.auto.pkrvars.hcl` may override `local_vm_settings` or `proxmox_settings` variables with your own values.
- `vehost.pkr.hcl` required configuration for post-build tasks, you must specify a valid SSH connection to the [VE platform](https://en.wikipedia.org/wiki/Comparison_of_platform_virtualization_software) specified in `config/config.mak`. You may leave blank if you don't care about post-build tasks (use `build_only=1` in your `make`).
- [`config/`](#config_dir)

### `config/`

- `config.mak` required configuration, `build_only`, `platform_ve`, `ansible_groups`.
- `ansible/`
  - `requirements.yaml` optional ansible-galaxy requirements file ran before provisioning.
  - `site.yaml` shared playbook for all images, target the images differently with the groups you specify in `config.mak`.

## Optimization

- Packer will automatically cache downloaded images on your machine
- Make will not rebuild images if they are unnecessary
- Make will only update your python virtual environment if it is out of date
