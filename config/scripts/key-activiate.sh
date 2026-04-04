#! /bin/sh

if ! command -v gpgconf >/dev/null 2>&1; then
  echo "gpgconf not found on PATH" >&2
  exit 1
fi

gpgconf --kill gpg-agent && gpg-connect-agent updatestartuptty /bye
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
ssh-add -L
