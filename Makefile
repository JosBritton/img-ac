-include config/config.mak

build_only  ?= 0
platform_ve ?= proxmox

ifeq ($(ansible_groups),)
$(error ansible_groups is not defined)
endif

define assert_boolean
$(if $(filter 1 0,$(value $(1))),,\
	$(error $(1) is not a boolean value (1 or 0))\
)
endef

$(call assert_boolean,build_only)

post_build_targets = $(foreach group,$(ansible_groups),phony/$(group)/post_build)

all: $(ansible_groups)
.PHONY: $(ansible_groups) all clean mostlyclean phony/build $(post_build_targets)

sources = main.pkr.hcl sources.pkr.hcl variables.pkr.hcl \
	config/ansible/requirements.yaml \
	$(wildcard *.pkrvars.hcl)

# allow build aliases for ansible groups and optionally skipping post-build tasks
$(ansible_groups): %: output/%/packer-base \
$(if $(filter 0,$(build_only)),phony/%/post_build)

MAKEFLAGS += --no-print-directory
.SECONDARY: output/%/packer-base
output/%/packer-base: $(sources) config/ansible/%.yaml
# 	ensure the temporary build keys are always removed
	@ /usr/bin/env sh -c \
		"trap 'trap - INT TERM; \
			rm -f .ssh/id_rsa .ssh/id_rsa.pub; \
			rmdir .ssh >/dev/null 2>&1' INT TERM ERR; \
		'$(MAKE)' target='$*' phony/build"

.venv/lock: requirements.txt
	python3 -m venv .venv

	. .venv/bin/activate; \
	python3 -m pip install -U -r requirements.txt

	touch .venv/lock

phony/build: .venv/lock
	$(if $(target),,$(error target is not defined))
	packer init .

	mkdir -p output/

	mkdir -m 700 -p .ssh
	echo y | ssh-keygen -q -N "" -f .ssh/id_rsa >/dev/null 2>&1

	. .venv/bin/activate; \
	packer build --only provision.qemu.base \
		--force \
		--var "ssh_public_key=$$(cat .ssh/id_rsa.pub)" \
		--var "ssh_private_key_file_path=.ssh/id_rsa" \
		--var "target=$(target)" .

	rm -f .ssh/id_rsa .ssh/id_rsa.pub
	rmdir .ssh

# packer will error if the file doesn't exist, so create a placeholder
define vehost_placeholder
# virtual environment host SSH connection
# (placeholder, replace with your actual values)
source "null" "vehost" {
    ssh_host = "127.0.0.1"
    ssh_username = "root"
    ssh_private_key_file = "/dev/null"
}
endef
vehost.pkr.hcl:
	@ echo Making placeholder file: vehost.pkr.hcl \
		(HINT: replace with your actual values!)
	$(file >$@,$(vehost_placeholder))

# ambiguous state of vehost, so remote operations should always be out of date
$(post_build_targets): phony/%/post_build: output/%/packer-base
	packer build --only veupload.null.vehost \
		--var "target=$*" .

	packer build --only "$(platform_ve).null.vehost" \
		--var "target=$*" .

clean:
	find output/ -mindepth 1 -delete
	rm -rf .venv/

mostlyclean:
	find output/ -mindepth 1 -delete
