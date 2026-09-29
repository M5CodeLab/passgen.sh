#!/usr/bin/env bash
# passgen.sh - automatic random password generator
# Randomness comes from the OS (/dev/urandom), so it is cryptographically strong.

set -eu

LENGTH=20
COUNT=1
MODE="full"
QUIET=0

LOWER='a-z'
UPPER='A-Z'
DIGITS='0-9'
SYMBOLS='!@#$%^&*()_+=<>?-'

usage() {
  cat <<EOF
Usage: $(basename "$0") [-l LENGTH] [-c COUNT] [-m MODE] [-q]

  -l LENGTH   password length / number of digits (default: 20)
  -c COUNT    how many passwords to generate      (default: 1)
  -m MODE     full   : letters + digits + symbols (default)
              alnum  : letters + digits only
              number : a random signed integer (-N ... +N), any number of digits
              mixed  : random characters followed by a random signed integer
  -q          quiet: print only the raw password (good for scripts/pipes)
  -h          show this help

Examples:
  $(basename "$0")                 # one 20-char password
  $(basename "$0") -l 32 -c 5      # five 32-char passwords
  $(basename "$0") -m number -l 50 # signed 50-digit number, e.g. -48213...
EOF
}

# rand_chars CHARSET LENGTH -> LENGTH random chars from CHARSET
rand_chars() {
  LC_ALL=C tr -dc "$1" < /dev/urandom | head -c "$2"
}

# rand_sign -> "+" or "-"
rand_sign() {
  LC_ALL=C tr -dc '+-' < /dev/urandom | head -c 1
}

# rand_number DIGITS -> signed integer with DIGITS digits (no leading zero)
rand_number() {
  local n=$1
  local sign first rest=""
  sign=$(rand_sign)
  first=$(rand_chars '1-9' 1)
  if [ "$n" -gt 1 ]; then
    rest=$(rand_chars '0-9' $((n - 1)))
  fi
  printf '%s%s%s' "$sign" "$first" "$rest"
}

gen_full() {
  local len=$1 pool="$2" pw
  while :; do
    pw=$(rand_chars "$pool" "$len")
    # make sure every required class appears at least once
    case "$pw" in *[a-z]*) ;; *) continue ;; esac
    case "$pw" in *[A-Z]*) ;; *) continue ;; esac
    case "$pw" in *[0-9]*) ;; *) continue ;; esac
    if [ "$MODE" = "full" ]; then
      case "$pw" in *[\!@\#\$%^\&*\(\)_+=\<\>?-]*) ;; *) continue ;; esac
    fi
    printf '%s' "$pw"
    return
  done
}

generate() {
  case "$MODE" in
    full)
      gen_full "$LENGTH" "${LOWER}${UPPER}${DIGITS}${SYMBOLS}"
      ;;
    alnum)
      gen_full "$LENGTH" "${LOWER}${UPPER}${DIGITS}"
      ;;
    number)
      rand_number "$LENGTH"
      ;;
    mixed)
      local half=$((LENGTH / 2))
      [ "$half" -lt 4 ] && half=4
      printf '%s%s' "$(gen_full "$half" "${LOWER}${UPPER}${DIGITS}${SYMBOLS}")" \
                    "$(rand_number "$half")"
      ;;
    *)
      echo "Unknown mode: $MODE" >&2
      usage >&2
      exit 1
      ;;
  esac
}

while getopts ":l:c:m:qh" opt; do
  case "$opt" in
    l) LENGTH=$OPTARG ;;
    c) COUNT=$OPTARG ;;
    m) MODE=$OPTARG ;;
    q) QUIET=1 ;;
    h) usage; exit 0 ;;
    \?|:) echo "Invalid option." >&2; usage >&2; exit 1 ;;
  esac
done

case "$LENGTH$COUNT" in
  ''|*[!0-9]*) echo "LENGTH and COUNT must be positive integers." >&2; exit 1 ;;
esac
if [ "$LENGTH" -lt 4 ] || [ "$COUNT" -lt 1 ]; then
  echo "LENGTH must be >= 4 and COUNT >= 1." >&2
  exit 1
fi

if [ -t 1 ]; then
  GREEN=$'\033[1;32m'; CYAN=$'\033[1;36m'; RESET=$'\033[0m'
else
  GREEN=''; CYAN=''; RESET=''
fi

i=1
while [ "$i" -le "$COUNT" ]; do
  pw=$(generate)
  if [ "$QUIET" -eq 1 ]; then
    printf '%s\n' "$pw"
  else
    printf '%sPassword #%d%s  (mode: %s, length: %d)\n' "$CYAN" "$i" "$RESET" "$MODE" "${#pw}"
    printf '  %s%s%s\n\n' "$GREEN" "$pw" "$RESET"
  fi
  i=$((i + 1))
done
