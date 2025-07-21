#!/bin/bash
# add this script to the end of the swapworkspaces within the hyprland.conf eg && this script
local_dir=$(dirname "${BASH_SOURCE[0]}")
source "$local_dir/mon_utils.sh"
source "$HOME/.config/hypr/hyprswap.conf"

current_mon_id=$(hyprctl activewindow | grep -oP '(?<=monitor: )\d+')
current_mon_name=$(hyprctl monitors | grep -A 1 "ID $current_mon_id" | grep "Monitor" | awk '{print $2}')

function show_help() {
  echo "Help menu:"
  echo "  -h | --help to show this menu"
  echo "  -f | --flip start the flippage"
}

function flip() {
  if [[ $enable_flip != "true" ]]; then
    return 0
  fi
  current=$1
  new=$2
  get_vertical_mons
  # if current isnt a vertical && new mon is a vertical then:
  if [[ ! " ${vertical_mons[@]} " =~ " $current " ]] && [[ " ${vertical_mons[@]} " =~ " $new " ]]; then
    :
  elif [[ " ${vertical_mons[@]} " =~ " $current " ]] && [[ ! " ${vertical_mons[@]} " =~ " $new " ]]; then
    :
  else
    echo "Monitors don't need to be flipped"
    return 0
  fi

  echo "flipping workspace"
  hyprctl dispatch focusmonitor $current
  hyprctl dispatch togglesplit
  hyprctl dispatch focusmonitor $new
  hyprctl dispatch togglesplit
  hyprctl dispatch focusmonitor $current
}

function test() {
  get_vertical_mons
  for p in ${vertical_mons[@]}; do
    echo $p
  done
}

# case $1 in
# -t)
#   test
#   ;;
# -f | --flip)
#   flip $2 $3
#   ;;
# *)
#   show_help
#   ;;
# esac
