#!/usr/bin/env sh
# shellcheck source=/dev/null
. .venv/bin/activate && ANSIBLE_FORCE_COLOR=1 PYTHONUNBUFFERED=1 .venv/bin/ansible-playbook "$@"
