#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
SECRETS_FILE="${REPO_ROOT}/secrets/secrets.nix"
AGE_KEY_FILE="${AGE_KEY_FILE:-${HOME}/.config/age/keys.txt}"
EDITOR_CMD="${EDITOR:-vi}"

usage() {
  cat <<EOF
Usage: rekey-secret.sh <secret-path>

Edit and re-encrypt one repo-managed secret using plain age.

Examples:
  ./config/scripts/rekey-secret.sh secrets/mbsyncrc.age
  ./config/scripts/rekey-secret.sh secrets/msmtp-config.age

Environment overrides:
  AGE_KEY_FILE=/path/to/keys.txt
  EDITOR=nvim
EOF
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

require_file() {
  if [[ ! -f "$1" ]]; then
    echo "Missing required file: $1" >&2
    exit 1
  fi
}

secret_rel_path() {
  local secret_path="$1"
  if [[ "$secret_path" = "${REPO_ROOT}/"* ]]; then
    secret_path="${secret_path#${REPO_ROOT}/}"
  fi
  printf '%s\n' "$secret_path"
}

secret_abs_path() {
  local secret_path="$1"
  if [[ "$secret_path" = /* ]]; then
    printf '%s\n' "$secret_path"
  else
    printf '%s\n' "${REPO_ROOT}/${secret_path}"
  fi
}

load_recipients() {
  local target="$1"

  REKEY_TARGET="$target" perl -ne '
    BEGIN {
      $target = $ENV{"REKEY_TARGET"};
      $found = 0;
    }

    if (/^\s*([A-Za-z0-9_-]+)\s*=\s*"(age1[0-9a-z]+)";?\s*$/) {
      $keys{$1} = $2;
      next;
    }

    if (/^\s*"\Q$target\E"\.publicKeys\s*=\s*\[([^\]]+)\]/) {
      $found = 1;
      my @aliases = grep { length $_ } split /\s+/, $1;
      for my $alias (@aliases) {
        if ($alias =~ /^age1[0-9a-z]+$/) {
          print "$alias\n";
        } elsif (exists $keys{$alias}) {
          print "$keys{$alias}\n";
        } else {
          print STDERR "Unknown recipient alias in secrets.nix: $alias\n";
          exit 2;
        }
      }
    }

    END {
      if (!$found) {
        print STDERR "No publicKeys entry found for $target\n";
        exit 3;
      }
    }
  ' "$SECRETS_FILE"
}

cleanup() {
  rm -f "${PLAINTEXT_TMP:-}" "${ENCRYPTED_TMP:-}"
}

case "${1:-}" in
  -h|--help)
    usage
    exit 0
    ;;
  "")
    usage >&2
    exit 1
    ;;
esac

require_cmd age
require_file "$AGE_KEY_FILE"
require_file "$SECRETS_FILE"

SECRET_REL="$(secret_rel_path "$1")"
SECRET_ABS="$(secret_abs_path "$1")"
require_file "$SECRET_ABS"

mapfile -t RECIPIENTS < <(load_recipients "$SECRET_REL")

if [[ "${#RECIPIENTS[@]}" -eq 0 ]]; then
  echo "No recipients resolved for ${SECRET_REL}" >&2
  exit 1
fi

PLAINTEXT_TMP="$(mktemp)"
ENCRYPTED_TMP="$(mktemp)"
trap cleanup EXIT

age --decrypt -i "$AGE_KEY_FILE" "$SECRET_ABS" > "$PLAINTEXT_TMP"
"$EDITOR_CMD" "$PLAINTEXT_TMP"

AGE_ARGS=(--encrypt)
for recipient in "${RECIPIENTS[@]}"; do
  AGE_ARGS+=(-r "$recipient")
done

age "${AGE_ARGS[@]}" -o "$ENCRYPTED_TMP" "$PLAINTEXT_TMP"
mv "$ENCRYPTED_TMP" "$SECRET_ABS"

echo "Re-encrypted ${SECRET_REL} for recipients:"
printf '  %s\n' "${RECIPIENTS[@]}"
