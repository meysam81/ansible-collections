#!/usr/bin/env bash
# Usage: try-login.sh <private key> <user> [host:port]
#
# Logs in to 127.0.0.1 as <user> with <private key> (plus <key>-cert.pub when
# it exists) and runs `true`. With host:port it asks for a -W forward instead
# and prints the first line the forwarded port sends: an SSH server's banner.
# No ssh_config, agent or known_hosts of the caller takes part.
set -u

key=$1
user=$2
forward=${3:-}

opts=(
  -F /dev/null
  -i "$key"
  -o IdentitiesOnly=yes
  -o IdentityAgent=none
  -o StrictHostKeyChecking=no
  -o UserKnownHostsFile=/dev/null
  -o BatchMode=yes
  -o PasswordAuthentication=no
  -o KbdInteractiveAuthentication=no
  -o ConnectTimeout=10
)
if [ -f "$key-cert.pub" ]; then
  opts+=(-o "CertificateFile=$key-cert.pub")
fi

if [ -n "$forward" ]; then
  # The forwarded sshd sends its banner first; our ident line and the EOF
  # after it make it hang up, so ssh exits instead of waiting for a timeout.
  printf 'SSH-2.0-probe\r\n' | timeout 20 ssh "${opts[@]}" -W "$forward" "$user@127.0.0.1" | head -n 1
  exit 0
fi

exec timeout 20 ssh "${opts[@]}" "$user@127.0.0.1" true
