#! /bin/sh

gpgconf --kill gpg-agent && gpg-connect-agent updatestartuptty /bye
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
ssh-add -L
