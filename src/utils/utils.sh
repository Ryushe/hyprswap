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
