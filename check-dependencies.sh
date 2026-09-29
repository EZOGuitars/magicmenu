#!/bin/sh
set -u

failures=0

check_command() {
  label=$1
  command_name=$2
  if command -v "$command_name" >/dev/null 2>&1; then
    printf 'OK   %-18s %s\n' "$label" "$(command -v "$command_name")"
  else
    printf 'MISS %-18s %s\n' "$label" "$command_name"
    failures=$((failures + 1))
  fi
}

check_path() {
  label=$1
  path=$2
  if [ -e "$path" ]; then
    printf 'OK   %-18s %s\n' "$label" "$path"
  else
    printf 'MISS %-18s %s\n' "$label" "$path"
    failures=$((failures + 1))
  fi
}

printf '%s\n' 'MagicMenu runtime dependency check'
check_command 'Omarchy CLI' omarchy
check_command 'Quickshell' quickshell
check_command 'Python 3' python3
check_command 'Hyprland control' hyprctl
check_path 'Omarchy shell helper' /usr/share/omarchy/bin/omarchy-shell
check_path 'Omarchy system helper' /usr/share/omarchy/bin/omarchy

printf '%s\n' '' 'Optional feature:'
if hyprctl plugins list 2>/dev/null | grep -qi hyprglass; then
  printf '%s\n' 'OK   Hyprglass          installed (Liquid Glass available)'
else
  printf '%s\n' 'INFO Hyprglass          not detected (Liquid Glass remains unavailable)'
fi

if [ "$failures" -gt 0 ]; then
  printf '\n%s\n' "Dependency check failed: $failures required item(s) missing."
  exit 1
fi

printf '\n%s\n' 'Dependency check passed.'
