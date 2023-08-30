# IMG-AC
(Images as code)

Cloud-init will handle the following (and is therefore, not managed here):
- DNS
- IP assignment
- Hostname
- Password
- Authorized keys
- Timezone
- NTP
- Additional users

Use `make all` to build, it injects a newly generated ssh key into the build process via the variables `ssh_public_key` and `ssh_private_key_file_path`, therefore you may skip this and specify your own key using the same variables.
