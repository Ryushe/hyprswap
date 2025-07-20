#!/bin/bash
local_dir=$(dirname "${BASH_SOURCE[0]}")
source $local_dir/src/utils/mon_utils.sh
source $local_dir/src/utils/utils.sh

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

print_config() {
  echo "#########################"
  echo "##   hyprswap config   ##"
  echo "#########################"
}

check_rust() {
  if command -v rustc >/dev/null 2>&1 && command -v cargo >/dev/null 2>&1; then
    echo "Rust is already installed"
  else
    echo "Rust not detected... installing with pacman"
    pacman -Sy --noconfirm rust
    echo "Rust installation complete"
  fi
}

check_hyprsome() {
  if command -v hyprsome >/dev/null 2>&1; then
    echo "hyprsome already installed"
  else
    echo "installing hyprsome with cargo"
    cargo install hyprsome
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

get_range() {
  ##### gets the diff between two number values $1 $2
  local val="$1"
  local gap="$2"
  range=()
  for ((i = val; i <= val + gap; i++)); do
    range+=("$i")
  done
  # echo "range=${range[0]}-${range[-1]}"
}

show_monitors() {
  declare -A monitor_list
  i=1
  for mon in ${mons[@]}; do
    echo "\$mon$i = $mon"
    monitor_list[mon$i]="$mon"
    i=$((i + 1))
  done

}

show_workspace_config() {
  local num_workspaces=$1
  i=1
  for mon in ${mons[@]}; do
    echo
    echo "# $mon"
    get_range $i $((num_workspaces - 1))
    for j in "${!range[@]}"; do
      r="${range[j]}"
      if [[ $j -eq 0 ]]; then
        echo "workspace=$r,monitor:$mon,default:true"
      else
        echo "workspace=$r,monitor:$mon"
      fi
    done
  done
}

show_bind_config() {
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

generate_hyprland_config() {
  key=""
  local hyprswap_cmd="bind = \$mainMod, $key, exec, hyprswap"
  echo
  echo "Time to output the config"
  echo

  # overwrite_config # check if user wants to overwrite cfg  # uncoment if want config file made again
  # prompts user how many want
  num_of_workspaces

  echo "outputing config..."
  sleep 1
  echo
  {
    print_config
    echo

    # if [[ "$default_config" == "true" ]]; then
    #   show_default_mon_config
    # else
    #   show_hypr_mons # gets the current cfg
    # fi
    # echo

    show_monitors # mon1=dp-2, etc
    echo

    show_workspace_config $num_workspaces
    echo

    show_bind_config $num_workspaces
    echo
    echo

    # Hyprsome keybinds
    keys=("X" "C" "R")
    declare -A keyMap=(
      [X]="--left"
      [C]="--right"
      [R]="--correct"
    )

    for key in "${keys[@]}"; do
      echo "bind = \$mainMod, $key, exec, hyprswap ${keyMap[$key]}"
    done
  } 2>&1 | tee /tmp/hyprswap # uncoment if want config file made again
  # echo "Created the config file at ~/.config/hypr/hyprswap.conf"
  # echo

  echo
  echo "------------------"
  echo "Add content above to your hyprland.conf file"
  echo "  - replace your current workspace configs with above content"

  ## auto add config to hyprswap
  # sleep 1
  # echo "Would you like to auto add the config?"
  # echo "  - nOTE: adds source {file} to bottom of hyprland.conf"
  # confirm_or_exit "Config not added to hyprland.conf"
  # echo "# hyprswap" >>$HOME/.config/hypr/hyprland.conf
  # mv /tmp/hyprswap $HOME/.config/hypr/hyprswap.conf
  # echo "source = \$HOME/.config/hypr/hyprswap.conf" >>$HOME/.config/hypr/hyprland.conf
  rm /tmp/hyprswap # dont actually need the config to be made
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
  check_rust
  echo

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
