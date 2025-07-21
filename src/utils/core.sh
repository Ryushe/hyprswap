#!/bin/bash
##### random utils
source "$HOME/.config/hypr/hyprswap.conf"

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

move_mouse() {
  main_resolution=$(hyprctl monitors | grep -Eo '[0-9]{3,}x[0-9]{3,}@[^ ]+ at 0x0' | awk '{print $1}' | sed 's/@.*//')
  IFS="x" read -r x y <<<"$main_resolution"
  x=$(((x / 2) - 8)) # makes no longer mess up flip
  y=$((y / 2))
  hyprctl dispatch movecursor $x $y
}

swap_config_mouse() {
  # only runs if enabled in config
  if [[ $center_mouse == "true" ]]; then
    move_mouse
  fi
}

correct_config_mouse() {
  # only runs if enabled in config
  if [[ $center_mouse_on_mon_fix == "true" ]]; then
    move_mouse
  fi
}
