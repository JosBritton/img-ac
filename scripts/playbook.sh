#!/usr/bin/env sh
. .venv/bin/activate && ANSIBLE_FORCE_COLOR=1 PYTHONUNBUFFERED=1 .venv/bin/ansible-playbook "$@"
