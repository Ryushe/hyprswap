#!/bin/bash
local_dir="$(dirname "${BASH_SOURCE[0]}")"
source "$local_dir/utils/core.sh"
source "$local_dir/utils/get_mons.sh"
source "$local_dir/utils/smart_flip.sh"
source "$HOME/.config/hypr/hyprswap.conf"

current_mon_id=$(hyprctl activewindow | grep -oP '(?<=monitor: )\d+')
current_mon_name=$(hyprctl monitors | grep -A 1 "ID $current_mon_id" | grep "Monitor" | awk '{print $2}')
reset_file="/tmp/hyprswap_reset"

double_click_reset_check() {
  if [[ -f "$reset_file" ]]; then
    # local current_time=$(date +%s)
    # local current_time=$(date +%s%3N)                      # GNU date for milliseconds
    # local last_changed_time=$(stat -c %Y "$reset_file")000 # append 3 zeros for ms

    local current_time_ms=$(date +%s%3N)                     # current time in ms (GNU date)
    local last_changed_time=$(stat -c %Y "$reset_file")      # seconds
    local last_changed_time_ms=$((last_changed_time * 1000)) # convert to ms
    local time_passed=$((current_time_ms - last_changed_time_ms))

    echo "Found reset_file"
    echo "Current time in ms: $current_time_ms"
    echo "File time in ms: $last_changed_time_ms"
    echo "Time passed: $time_passed"
    # Check if file is recent (within 2 seconds)
    if [[ $time_passed -le $double_click_delay ]]; then
      rm $reset_file
      echo "Running correct workspaces"
      $local_dir/../correct_workspaces.sh -d
      exit 0
    else
      # File too old, reset it
      touch "$reset_file"
      return 0
    fi
  else
    touch "$reset_file"
    return 0
  fi
}
if [[ $double_click_reset == "true" ]]; then
  double_click_reset_check
fi

declare -A monitor_moves
#left  right movements
monitor_moves["$left_mon"]="$right_mon $main_mon"
monitor_moves["$main_mon"]="$left_mon $right_mon"
monitor_moves["$right_mon"]="$main_mon $left_mon"

possible_moves=${monitor_moves[$current_mon_name]}

if [[ $1 = "l" ]]; then
  new_mon=$(echo "$possible_moves" | awk '{print $1}')
elif [[ $1 = "r" ]]; then
  new_mon=$(echo "$possible_moves" | awk '{print $2}')
else
  echo "cant move monitor to nowhere... please give 'r' or 'l'"
fi
echo "moving $current_mon_name to $new_mon"
hyprctl dispatch swapactiveworkspaces $current_mon_name $new_mon
flip $current_mon_name $new_mon # can be disabled within config
swap_config_mouse               # can be disabled within config

# working on it currently doesnt seem to do much implement logging
# if left mon and moving left || right mon moving right

# not sure why this is here
# if [[ $current_mon_name == $left_mon && $1 == "l" || $current_mon_name == $right_mon && $1 == "r" ]]; then
#   :
# else
#   echo "moving mouse to $main_mon"
#   hyprctl dispatch focusmonitor $main_mon
# fi
