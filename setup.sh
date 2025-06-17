#!/bin/bash
local_dir=$(dirname "${BASH_SOURCE[0]}")
source $local_dir/src/utils/mon_utils.sh

show_help() {
  echo "################"
  echo "##   HELPER   ##"
  echo "################"
  echo
  echo "  -h | --help               shows this menu"
  echo "  -d | --default            generates a default config (doesn't base it off your current hyprland.conf)"
  echo "  no flags (eg: ./setup.sh) generates a config based off of your current hyprland.conf"
}

print_banner() {
  echo "#########################"
  echo "##     SETUP UTIL      ##"
  echo "#########################"
}

print_config() {
  echo "#####################"
  echo "##     config      ##"
  echo "#####################"
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

check_root() {
  echo "checking root (running without root won't run the installer):"

  if [[ "$EUID" -ne 0 ]]; then
    echo "You are not root                -> will only generate the config"
    sleep 2
    return 1
  fi
  echo "Running as root"

  return 0
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

show_current_mon_config() {
  space_range=1
  for ((i = 0; i < ${#hypr_mons[@]}; i++)); do
    echo ${hypr_mons[i]} # lines from current config
    echo "workspace=${mons[i]},$space_range"
    space_range=$((space_range + num_workspaces))
  done

}
move_app() {
  local dir="/opt/"
  echo "Moving hyprsome into $dir"
  mkdir -p /opt/hyprswap
  cp -rT --remove-destination "$local_dir" /opt/hyprswap/
  sleep 1
  echo "Moved into /opt/hyprswap"

}

ln_app() {
  echo "Installing hyprswap"
  sleep 1
  rm /usr/bin/hyprswap
  ln -s /opt/hyprswap/hyprswap.sh /usr/bin/hyprswap
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

generate_config() {
  key=""
  local hyprswap_cmd="bind = \$mainMod, $key, exec, hyprswap"
  echo
  echo "Time to generate the config"
  # prompts user how many want
  num_of_workspaces

  echo "making example config..."
  sleep 1
  echo "Replace position with where the montiors are (eg: 0x0 | -1920x0)"
  echo

  print_config
  echo

  if [[ ! $default_config ]]; then
    show_default_mon_config
  else
    show_current_mon_config
  fi
  echo

  show_monitors # mon1=dp-2, etc
  echo

  show_workspace_config $num_workspaces
  echo

  show_bind_config $num_workspaces
  echo

  echo # Hyprsome keybinds

  keys=("X" "C" "R")
  declare -A keyMap=(
    [X]="--left"
    [C]="--right"
    [R]="--correct"
  )

  for key in "${keys[@]}"; do
    echo "bind = \$mainMod, $key, exec, hyprswap ${keyMap[$key]}"
  done

}

handle_flags() {
  case "$1" in
  -h | --help)
    show_help
    exit 1
    ;;
  -d | --default)
    default_config=true
    shift
    ;;
  *)
    shift
    ;;
  esac
}

main() {
  default_config=false
  res="1920x1080"
  hrtz="60"
  print_banner
  echo

  handle_flags $1 # handles args

  if $default_config; then
    echo -e "\e[32mUsing Default Config\e[0m"
    echo -e "\e[34mNext time run without \e[31m-d\e[0m \e[34mto generate with current hyprland.conf monitor setup\e[0m"

  else
    echo -e "\e[32mUsing current hyprland.conf monitor config\e[0m"
    echo -e "\e[34mNext time run with \e[31m-d\e[0m \e[34mto generate a 'Default' monitor config\e[0me
  fi

  get_hypr_mons # gets current config
  get_mons

  if check_root; then
    echo
    echo "Would you like to run the installer?"
    echo "[y/n]"
    read -r choice
    # conv to lower
    choice=${choice,,}
    if [[ $choice != "y" ]]; then
      echo
      echo "Ok, I didn't install anything exiting.."
      echo
      echo "Rerun without sudo to just generate the config"
      exit 1
    fi
  else
    echo
    generate_config
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

  echo -e "\e[32mRe-run as user to generate the config\e[0m"
}
main "$@"
