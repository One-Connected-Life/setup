#!/bin/bash
# Called by local.yml: run MAC_SETUP_DIR/playbook.yml with ARGS.
# usage: run-mac-setup.sh MAC_SETUP_DIR [ansible-playbook args...]
#
# Ansible gives a task no terminal, so the playbook's prompts (git name,
# sudo password) could not be answered and its output would only show at the
# end. So this finds the terminal ansible-pull was started from and runs the
# playbook on it: live output, working prompts. With no terminal (cron, CI) it
# runs plainly and local.yml prints the output afterwards.
cd "$1" || exit 1
shift
unset ANSIBLE_CONFIG   # use the playbook repo's ansible.cfg

# Only ever the terminal of the ansible-pull process itself: walk up to the
# nearest ancestor whose command is ansible-pull (argv[0], or argv[1] after its
# python) and take its tty. No such ancestor, or it has none: no terminal.
# Never another ancestor's tty (that could be some unrelated window).
is_ansible_pull() {
  set -- $(ps -o args= -p "$1")
  [ "${1##*/}" = ansible-pull ] || [ "${2##*/}" = ansible-pull ]
}
pid=$(ps -o ppid= -p $$ | tr -d ' ') tty= owner=
while [ -n "$pid" ] && [ "$pid" -gt 1 ]; do
  if is_ansible_pull "$pid"; then
    t=$(ps -o tty= -p "$pid" | tr -d ' ')
    if [ -n "$t" ] && [ "$t" != "??" ]; then
      tty=/dev/$t owner=$pid
    fi
    break
  fi
  pid=$(ps -o ppid= -p "$pid" | tr -d ' ')
done

if [ -z "$tty" ] || [ ! -w "$tty" ]; then
  exec ansible-playbook playbook.yml "$@"
fi

# script(1) gives the playbook its own pty as controlling terminal (pause needs one).
script -q /dev/null ansible-playbook playbook.yml "$@" <"$tty" >"$tty" 2>&1 &
child=$!
# Ctrl-C ends ansible-pull but not this run (it has its own session):
# stop the playbook when the process that owns the terminal is gone.
while kill -0 "$child" 2>/dev/null; do
  if ! kill -0 "$owner" 2>/dev/null; then
    kill "$child"
    break
  fi
  sleep 1
done
wait "$child"
