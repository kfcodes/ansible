#!/usr/bin/env bash
# Molecule test runner for this project.
#
#   ./run_molecule.sh list                          show what can be tested
#   ./run_molecule.sh all [command]                 syntax-check every playbook, then run
#                                                   every scenario (default command: test)
#   ./run_molecule.sh <role> [command] [args...]    one role, e.g. ./run_molecule.sh system_dev converge
#   ./run_molecule.sh <scenario> [command] [args]   a project scenario in molecule/, e.g. ./run_molecule.sh site
#   ./run_molecule.sh new <role>                    add a starter Molecule scenario to a role
#   ./run_molecule.sh images                        rebuild the systemd test images
#
# Commands are Molecule's: test (default), syntax, check, converge, verify,
# idempotence, login -h <host>, destroy, reset.
# MOLECULE_DEBUG=1 ./run_molecule.sh <target> adds --debug.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGES_DIR="$ROOT/.config/molecule/images"
export MOLECULE_REPO_ROOT="$ROOT"
export ANSIBLE_ROLES_PATH="$ROOT/roles"

die() { echo "error: $*" >&2; exit 1; }

usage() { sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'; }

role_targets() {
  local f
  for f in "$ROOT"/roles/*/molecule/default/molecule.yml; do
    [[ -f $f ]] || continue
    f=${f%/molecule/default/molecule.yml}
    echo "${f##*/}"
  done
}

project_targets() {
  local f
  for f in "$ROOT"/molecule/*/molecule.yml; do
    [[ -f $f ]] || continue
    f=${f%/molecule.yml}
    echo "${f##*/}"
  done
}

roles_without_tests() {
  local d
  for d in "$ROOT"/roles/*/; do
    [[ -d ${d}molecule ]] || basename "$d"
  done
}

playbooks() {
  local pb
  for pb in "$ROOT"/site.yml "$ROOT"/playbooks/*.yml; do
    [[ -f $pb ]] && echo "${pb#"$ROOT"/}"
  done
}

# Build the systemd images from .config/molecule/images/ (force=1 rebuilds).
build_images() {
  local force=${1:-0} df tag
  command -v docker >/dev/null 2>&1 || { echo "docker not found" >&2; return 1; }
  for df in "$IMAGES_DIR"/Dockerfile.*; do
    [[ -f $df ]] || continue
    tag="molecule-systemd:${df##*.}"
    if [[ $force == 1 ]] || ! docker image inspect "$tag" >/dev/null 2>&1; then
      echo ">>> Building test image $tag"
      docker build -t "$tag" -f "$df" "$IMAGES_DIR" || return 1
    fi
  done
}

# Returns 0 = passed, 1 = failed, 2 = skipped.
run_target() {
  local target=$1 cmd=$2 dir file
  shift 2
  local -a scenario=()
  if [[ -f $ROOT/roles/$target/molecule/default/molecule.yml ]]; then
    dir=$ROOT/roles/$target
    file=$dir/molecule/default/molecule.yml
  elif [[ -f $ROOT/molecule/$target/molecule.yml ]]; then
    dir=$ROOT
    file=$ROOT/molecule/$target/molecule.yml
    scenario=(-s "$target")
  else
    echo "No Molecule scenario for '$target'. See: ./run_molecule.sh list" >&2
    if [[ -d $ROOT/roles/$target ]]; then
      echo "Add one with: ./run_molecule.sh new $target" >&2
    fi
    return 1
  fi

  if grep -qE '^[[:space:]]*name:[[:space:]]*vagrant' "$file"; then
    if ! command -v vagrant >/dev/null 2>&1; then
      echo ">>> $target: skipped (needs Vagrant + VirtualBox)"
      return 2
    fi
  elif grep -q 'molecule-systemd' "$file" || ! grep -qE '^platforms:' "$file"; then
    # Uses the shared systemd platforms from .config/molecule/config.yml
    build_images 0 || return 1
  fi

  (cd "$dir" && molecule ${MOLECULE_DEBUG:+--debug} "$cmd" "${scenario[@]}" "$@")
}

run_all() {
  local cmd=${1:-test} pb t rc failed=0 log
  local -a results=()
  log=$(mktemp)

  echo "=== Syntax check: playbooks"
  while read -r pb; do
    if (cd "$ROOT" && ansible-playbook --syntax-check "$pb" >"$log" 2>&1); then
      results+=("PASS     syntax    $pb")
    else
      cat "$log"
      results+=("FAIL     syntax    $pb")
      failed=1
    fi
  done < <(playbooks)

  for t in $(role_targets) $(project_targets); do
    echo
    echo "=== Molecule $cmd: $t"
    run_target "$t" "$cmd"
    rc=$?
    case $rc in
      0) results+=("PASS     molecule  $t") ;;
      2) results+=("SKIPPED  molecule  $t") ;;
      *) results+=("FAIL     molecule  $t"); failed=1 ;;
    esac
  done
  rm -f "$log"

  for t in $(roles_without_tests); do
    results+=("NO TEST  molecule  $t   (add: ./run_molecule.sh new $t)")
  done

  echo
  echo "=== Summary"
  printf '%s\n' "${results[@]}"
  return $failed
}

list_targets() {
  echo "Role scenarios (./run_molecule.sh <role>):"
  role_targets | sed 's/^/  /'
  echo "Project scenarios in molecule/ (./run_molecule.sh <name>):"
  project_targets | sed 's/^/  /'
  echo "Roles without tests (./run_molecule.sh new <role>):"
  roles_without_tests | sed 's/^/  /'
  echo "Playbooks (syntax-checked by ./run_molecule.sh all):"
  playbooks | sed 's/^/  /'
}

new_scenario() {
  local role=$1 d
  [[ -d $ROOT/roles/$role ]] || die "roles/$role does not exist"
  d=$ROOT/roles/$role/molecule/default
  [[ -e $d ]] && die "$d already exists"
  mkdir -p "$d"

  cat > "$d/molecule.yml" <<EOF
---
# Driver and platforms (Rocky 10 + Ubuntu 24.04 systemd containers) come from
# .config/molecule/config.yml at the repository root.
#   ./run_molecule.sh $role
provisioner:
  name: ansible
  playbooks:
    prepare: \${MOLECULE_REPO_ROOT}/.config/molecule/prepare.yml
  inventory:
    group_vars:
      all:
        local_usr: devtest
        # Add the variables $role needs here (test values, no real secrets).
EOF

  cat > "$d/converge.yml" <<EOF
---
- name: Converge
  hosts: all
  become: true
  tasks:
    - name: Apply $role
      ansible.builtin.include_role:
        name: $role
EOF

  cat > "$d/verify.yml" <<EOF
---
# Replace the placeholder with checks of what $role should leave behind:
# packages (ansible.builtin.package_facts), services (service_facts),
# files (stat), ports (wait_for), then ansible.builtin.assert.
- name: Verify
  hosts: all
  become: true
  gather_facts: false
  tasks:
    - name: Placeholder until real checks are added
      ansible.builtin.debug:
        msg: "TODO: add assertions for $role"
EOF

  echo "Created $d"
  echo "Next: add required variables to molecule.yml, then run ./run_molecule.sh $role"
}

case "${1:-}" in
  ""|-h|--help|help) usage ;;
  list) list_targets ;;
  images) build_images 1 ;;
  new)
    [[ $# -ge 2 ]] || die "usage: ./run_molecule.sh new <role>"
    new_scenario "$2"
    ;;
  all)
    shift
    run_all "${1:-test}"
    ;;
  *)
    target=$1
    shift
    cmd=test
    if [[ $# -gt 0 && "$1" != -* ]]; then
      cmd=$1
      shift
    fi
    run_target "$target" "$cmd" "$@"
    rc=$?
    [[ $rc == 2 ]] && rc=0
    exit $rc
    ;;
esac
