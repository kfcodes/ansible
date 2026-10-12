#!/bin/bash
# run_molecule.sh

export ANSIBLE_ROLES_PATH="$(pwd)/roles"
cd roles/system_base_config
molecule --debug test
# molecule test
