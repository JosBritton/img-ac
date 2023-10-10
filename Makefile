SHELL := /usr/bin/env sh

-include config/config.mak

build_only      ?=
platform_ve     ?= proxmox
parallel_builds ?= $(shell nproc || sysctl -n hw.ncpu || echo 1)

MAKEFLAGS += --jobs=$(parallel_builds)

ifeq ($(ansible_groups),)
$(error ansible_groups is not defined)
endif
.PHONY: $(sort $(ansible_groups))

post_build_targets = $(foreach group,$(sort $(ansible_groups)),phony/$(group)/post_build)
.PHONY: $(post_build_targets)

.PHONY: all
.DEFAULT_GOAL: all
all: $(sort $(ansible_groups))

sources = main.pkr.hcl sources.pkr.hcl variables.pkr.hcl \
	config/ansible/requirements.yaml plugin.pkr.hcl \
	$(wildcard *.pkrvars.hcl)

# allow build aliases for ansible groups and optionally skipping post-build tasks
$(ansible_groups): %: output/%/packer-kvm.img \
$(if $(build_only),,phony/%/post_build)

.SECONDARY: output/%/packer-kvm.img
output/%/packer-kvm.img: $(sources) config/ansible/%.yaml \
.venv/lock plugin.pkr.hcl.lock /tmp/packer/id_% /tmp/packer/id_%.pub | output/
	. .venv/bin/activate && \
	packer build --only "$*.qemu.kvm" \
		--force \
		--var "target=$*" . && \
	packer build --only "$*.null.post" \
		--var "target=$*" .

	rm -f "/tmp/packer/id_$*" "/tmp/packer/id_$*.pub"

.INTERMEDIATE: /tmp/packer/id_%.pub
/tmp/packer/id_% /tmp/packer/id_%.pub:
	mkdir -p -m 700 /tmp/packer/
	echo y | ssh-keygen -q -N "" -C "" -f "$@" >/dev/null 2>&1

.venv/lock: requirements.txt
	python3 -m venv .venv

	. .venv/bin/activate; \
	python3 -m pip install -U -r requirements.txt

	touch .venv/lock

plugin.pkr.hcl.lock: plugin.pkr.hcl
	packer init .
	touch "$@"

output/:
	mkdir output/

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
	@ printf "%s\n" "Making placeholder file: vehost.pkr.hcl" \
		"HINT: replace with your actual values"
	$(file >$@,$(vehost_placeholder))

# ambiguous state of vehost, so remote operations should always be out of date
$(post_build_targets): phony/%/post_build: output/%/packer-kvm.img
	. .venv/bin/activate && \
	packer build --only "veupload.null.vehost" \
		--var "target=$*" . && \
	packer build --only "$(platform_ve).null.vehost" \
		--var "target=$*" .

.PHONY: clean
clean: mostlyclean
	rm -rf .venv/

.PHONY: mostlyclean
mostlyclean:
	find /tmp/packer/ output/ -mindepth 1 -delete
