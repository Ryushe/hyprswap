#!/bin/bash
##### random utils

confirm_or_exit() {
  echo "[y/n]"
  read -r choice
  choice=${choice,,}
  if [[ ! $choice == "y" ]]; then
    echo "$1"
    echo "Exiting..."
    exit 1
  fi
}

check_root() {
  echo "checking root:"

  if [[ "$EUID" -ne 0 ]]; then
    echo "You are not root"
    echo "Please re-run as root user"
    exit 1
  fi
  echo "Running as root"
}

check_if_user() {
  echo "checking if user:"

  if [[ ! "$EUID" -ne 0 ]]; then
    echo "You are root"
    echo "Please don't run this script as sudo user"
  fi
  echo "Continuing as user"
}

is_dir() {
  dir = $1
  if [[ -d "$1" ]]; then
    return 0
  fi
  return 1
}
