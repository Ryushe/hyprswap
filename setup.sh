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
  echo "  -d | --default            generates a default config (doesn't base it off your current hyprland.conf)"
  echo "  -c | --current            generates a config based off of your current hyprland.conf"
  echo "  -i | --installer          runs installer"
  echo "  -a | --all                installs hyprswap and generates config file using current hyprland monitor setup"
  echo "                              - adds source for hyprswap.conf in hyprland.conf as well"
}

print_banner() {
  echo "#########################"
  echo "##     SETUP UTIL      ##"
  echo "#########################"
}

# check_rust() {
#   if command -v rustc >/dev/null 2>&1 && command -v cargo >/dev/null 2>&1; then
#     echo "Rust is already installed"
#   else
#     echo "Rust not detected... please install with pacman"

#     # pacman -Sy --noconfirm rust
#     echo
#     echo "run:"
#     echo "sudo pacman -S rust"
#     echo
#     echo "Then rerun the script"
#     exit 1
#   fi
# }

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

num_of_workspaces() {
  echo "How many workspaces would you like per monitor"
  echo "Default: 10"
  read -r workspaces
  num_workspaces=${workspaces:-10}
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

  local num_workspaces=$1
  i=1
  get_range $i $((num_workspaces - 1))
  for r in ${range[@]}; do
    p=$r
    if [[ $p -gt 10 ]]; then
      p=${p:1} # if 2 digets takes off the 1st so 21 = 1
    fi
    echo "bind = \$mainMod, $p, exec, hyprsome workspace $r"
  done
  echo

  for r in ${range[@]}; do
    p=$r
    if [[ $p -gt 10 ]]; then
      p=${p:1} # if 2 digets takes off the 1st so 21 = 1
    fi
    echo "bind = \$mainMod SHIFT, $p, exec, hyprsome workspace $r"
  done

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

make_config() {
  echo "Making config in $config_dir/$config_file"
  if [[ ! -d "$config_dir" ]]; then
    mkdir -p "$config_dir"
  fi
  if [[ -f "$config_dir/$config_file" ]]; then
    echo "config already exists, skipping"
    return 0
  fi

  cp $default_config $config_dir/$config_file
  echo "Config sucessfully made!"
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

  make_config
  echo
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
  -d | --default)
    default_config=true
    echo -e "\e[32mUsing Default Config\e[0m"
    echo
    shift
    generate_hyprland_config
    exit 1
    ;;
  -i | --installer)
    run_installer
    exit 1
    ;;
  -c | --current)
    echo -e "\e[32mUsing current hyprland.conf monitor config\e[0m"
    default_config=false
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
