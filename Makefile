.PHONY: all envoy-lb clear _trap _build

all: envoy-lb

.venv:
	python3 -m venv .venv
	. .venv/bin/activate && pip install -U -r requirements.txt

envoy-lb: out/envoy-lb

out/envoy-lb: .venv
	@ "${MAKE}" DIR=envoy-lb _trap

export _clean = rm -f .ssh/id_rsa .ssh/id_rsa.pub; rmdir --ignore-fail-on-non-empty .ssh; exit

clear:
	find out/ -mindepth 1 -delete

_trap:
	/usr/bin/env sh -c "trap 'trap - INT TERM; ${_clean}' INT TERM ERR; \"${MAKE}\" DIR=\"${DIR}\" _build"

_build:
#	test DIR is set and not empty
	/usr/bin/env sh -c 'if ! test -n "$${DIR:+1}"; then exit 1; fi'

	mkdir -m 700 -p .ssh
	echo y | ssh-keygen -q -N "" -f .ssh/id_rsa >/dev/null 2>&1

	packer build -var "dir=${DIR}" \
		-var "ssh_public_key=$$(cat .ssh/id_rsa.pub)" \
		-var "ssh_private_key_file_path=.ssh/id_rsa" .

	${_clean}
