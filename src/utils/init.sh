#!/bin/bash
# runs on first launch
local_dir=$(dirname "${BASH_SOURCE[0]}")
source $local_dir/mon_utils.sh
source $local_dir/installer_core.sh

config_dir="$HOME/.config/hypr"
config_file="hyprswap.conf"
config_path="$config_dir/$config_file"

print_intro() {
  echo "Welcome to Hyprswap!! A plugin designed to allow anyone to move their monitors where they want, when they want!"
  echo "  - This is all made possible due to Hyprsome, so go so them some love!"
}

function get_config() {
  # way to handle the changing of paths when aur or installed locally
  local local_default="$(dirname "$(realpath "$0")")/assets/default_config.conf"
  local default_config=""

  if [[ -f "$local_default" ]]; then
    default_config="$local_default"
  else
    default_config="/usr/share/hyprswap-git/assets/default_config.conf"
  fi
  echo $default_config
}

function set_config() {
  local default_config=$1

  if [[ ! -f "$config_path" ]]; then
    cp "$default_config" "$config_path"
    echo "Copied config"
    echo "Config path: $config_path"
  fi
}

main() {
  local config=$(get_config)
  declare -A monitor_list

  print_intro
  echo

  # leave here - my dumbass is just ckeckign the default config flag in the script
  get_hypr_mons # gets current config - currently not outputting it in installer_core.sh
  get_mons

  set_config $config

  # handle_flags $1 # handles args (enable if want flags again) <- pull from local_installer
  default_config=false
  generate_hyprland_config
}
main "$@"
