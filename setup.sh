#!/bin/bash
local_dir=$(dirname "${BASH_SOURCE[0]}")
source $local_dir/src/utils/mon_utils.sh
source $local_dir/src/utils/core.sh
source $local_dir/src/utils/installer_core.sh

default_config="assets/default_config.conf"
config_dir="$HOME/.config/hypr"
config_file="hyprswap.conf"
dir="${HOME}/.local/share/hyprswap"

show_help() {
  echo "Help menu:"
  echo
  echo "  -h | --help               shows this menu"
  echo "  -g | --generate           generates the config to go into your hyprland.conf"
  echo "  -i | --installer          runs installer"
  echo "  -a | --all                installs hyprswap and generates config file using current hyprland monitor setup"
  echo "                              - adds source for hyprswap.conf in hyprland.conf as well"
}

print_banner() {
  echo "#########################"
  echo "##     SETUP UTIL      ##"
  echo "#########################"
}

check_hyprsome() {
  if command -v hyprsome >/dev/null 2>&1; then
    echo "hyprsome already installed"
  else
    echo "installing hyprsome..."
    if command -v yay >/dev/null 2>&1; then
      yay -Sy hyprsome
    elif command -v paru >/dev/null 2>&1; then
      paru -Sy hyprsome
    else
      echo
      echo "No AUR helper found. Please install hyprsome manually."
      echo "Options:"
      echo "  - yay, paru or cargo install hyprsome"
      exit 1
    fi
  fi
}

show_default_mon_config() {
  space_range=1
  for mon in ${mons[@]}; do
    echo "monitor=$mon,$res@$hrtz,position,1"
    echo "workspace=$mon,$space_range"
    space_range=$((space_range + num_workspaces))
  done
}

move_app() {
  echo "Moving hyprsome into $dir"
  if [[ ! -d "$dir/hyprswap" ]]; then
    mkdir -p $dir/hyprswap
  fi
  cp -rT --remove-destination "$local_dir" $dir
  sleep 1
  echo "Moved into $dir/hyprswap"

}

ln_app() {
  echo "Installing hyprswap"
  sleep 1
  rm $HOME/.local/bin/hyprswap
  ln -s $dir/hyprswap.sh $HOME/.local/bin/hyprswap
  echo "Installed hyprswap"
}

overwrite_config() {
  cfg=$(find "$HOME/.config/hypr/" -maxdepth 1 -name "hyprswap.conf" -print -quit 2>/dev/null)
  if [[ -n $cfg ]]; then
    echo "Creating the config overwrites the previous one at ~/.config/hypr/hyprswap.conf"
    echo "[y/n]"
    read -r choice
    choice=${choice,,}
    if [[ ! $choice == "y" ]]; then
      echo "Didn't overwrite file, exiting..."
      exit 1
    fi

    echo "Continuing"
  fi
}

run_installer() {
  check_if_user
  echo "Would you like to run the installer?"
  echo "[y/n]"
  read -r choice
  # conv to lower
  local choice=${choice,,}
  if [[ $choice != "y" ]]; then
    echo
    echo "Ok, I didn't install anything exiting.."
    exit 1
  fi

  # check_rust
  # echo

  check_hyprsome
  echo

  move_app
  echo

  ln_app
  echo

  # maybe init the app -> probably just do this on first run
}

run_all() {
  run_installer
  generate_hyprland_config
}

handle_flags() {
  case "$1" in
  -h | --help)
    show_help
    exit 1
    ;;
  # -d | --default)
  #   default_config=true
  #   echo -e "\e[32mUsing Default Config\e[0m"
  #   echo
  #   shift
  #   generate_hyprland_config
  #   exit 1
  #   ;;
  -i | --installer)
    run_installer
    exit 1
    ;;
  -g | --generate)
    # echo -e "\e[32mUsing current hyprland.conf monitor config\e[0m"
    # default_config=false
    generate_hyprland_config
    shift
    ;;
  -a | --all)
    echo -e "\e[32mUsing current hyprland.conf monitor config\e[0m"
    default_config=false
    run_all
    exit 1
    ;;
  *)
    show_help
    ;;
  esac
}

main() {
  declare -A monitor_list
  install_location="$HOME/.local/share/hyprswap"
  res="1920x1080"
  hrtz="60"
  print_banner
  echo

  # leave here - my dumbass is just ckeckign the default config flag in the script
  get_hypr_mons # gets current config
  get_mons

  handle_flags $1 # handles args

}
main "$@"
