#!/bin/bash
local_dir=$(dirname "${BASH_SOURCE[0]}")
source "$local_dir/utils/get_mons.sh"
source "$local_dir/utils/core.sh"
source "$local_dir/utils/smart_flip.sh"

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
declare -A current_orientation
declare -A correct_orientation

option=$1

function show_help() {
  echo "Help menu:"
  echo "  -h | --help to show this menu"
  echo "  -r | --run start the app"
  echo "  -s | --check where the workspaces are"
  echo "  -d | --dev work on the 'dev' branch"
  echo "  -e compare current to the correct config"
  echo "  -c get current orinetation"
}

function get_current_orientation() {
  while IFS=': ' read -r mon ws; do
    echo "Monitor=$mon, Workspace=$ws"
    current_orientation["$mon"]="$ws"
  done < <(hyprctl monitors -j | jq -r '.[] | "\(.name): \(.activeWorkspace.id)"')
}

function get_correct_orientation() {
  ws_list=()

  mapfile -t orientation < <(grep -E '^\s*workspace=' "$HOME/.config/hypr/hyprland.conf")
  for line in "${orientation[@]}"; do
    IFS='=, ' read -r _ mon ws <<<"$line"
    correct_orientation["$mon"]="$ws"
    ws_list+=("$ws")
  done
  get_space_gap
  for mon in "${!correct_orientation[@]}"; do
    ws="${correct_orientation[$mon]}"
    echo "Monitor=$mon, Range=$ws-$((ws + space_gap))"
  done
}

function workspace_good() {
  local mon=$1
  local ws=$2
  local correct_ws="${correct_orientation[$mon]}"
  get_range $correct_ws $space_gap # gets an array of the workspace range eg: 11-20 - uses ws
  if ! is_in_array "$ws" "${range[@]}"; then
    echo "$mon is at $ws which is bad, correct space: $correct_ws"
    return 1
  fi
  echo "$mon is at $ws which is good"
  return 0
}

function find_new_mon() {
  #### takes the known ending location and converts it to a monitor
  local ws=$1
  get_space_gap &>/dev/null
  # instaed of this, need to check if its within the range of the workspace
  for mon in "${!correct_orientation[@]}"; do
    local correct_ws="${correct_orientation[$mon]}"

    get_range "$correct_ws" "$space_gap" &>/dev/null
    if is_in_array "$ws" "${range[@]}"; then
      echo $mon
      return 0
    fi
  done
  return 1
}

function move_workspace() {
  ## finishing
  local current_mon_name=$1
  local ws=$2
  # ws instead of new, because we want to find the monitor that correlates with our current workspace
  echo "Finding mon for workspace $ws"
  new_mon=$(find_new_mon $ws)
  echo moving $current_mon_name to $new_mon
  hyprctl dispatch swapactiveworkspaces $current_mon_name $new_mon &>/dev/null
}

function move_workspace_old() {
  local ws=$1
  local correct_ws=$2
  if (($ws > $correct_ws)); then
    $script_dir/swap_active_workspaces.sh l
    return
  fi
  $script_dir/swap_active_workspaces.sh r
}

function is_in_array() {
  local val="$1"
  shift
  for i; do [[ "$i" -eq "$val" ]] && return 0; done
  return 1
}

function compare_orientations() {
  #### this is for visual guide, shows you what monitors have changed between hyprland conf and current
  echo "Diff:"
  get_current_orientation >/tmp/current.txt
  get_correct_orientation >/tmp/correct.txt
  diff --changed-group-format='%<' --unchanged-group-format='' /tmp/current.txt /tmp/correct.txt
  # idea: add maybe sleep then remove txt files
}

function get_range() {
  ##### gets the diff between two number values $1 $2
  local val="$1"
  local gap="$2"
  range=()
  for ((i = val; i <= val + gap; i++)); do
    range+=("$i")
  done
  echo "range=${range[0]}-${range[-1]}"
}

function get_space_gap() {
  ##### gets the range between 1st mon and 2nd mon to see what workspaces go where
  if ((${#ws_list[@]} >= 2)); then
    space_gap=$(((ws_list[1] - 1) - ws_list[0])) # -1 to account for starting with 1 since indexes are off 0
    echo "Workspace gap: $((space_gap + 1))"
  else
    echo "Not enough workspaces to calculate gap"
  fi
}

# currently using - added ability to flip vertical and back
function main() {
  echo "Current:"
  get_current_orientation
  echo
  echo "Correct:"
  get_correct_orientation
  echo

  local changed=1
  while ((changed)); do
    changed=0
    for mon in "${!current_orientation[@]}"; do
      local ws="${current_orientation[$mon]}"
      if ! workspace_good "$mon" "$ws"; then
        move_workspace "$mon" "$ws"
        echo -e "\nFlip Workspace:"
        correct_mon=$(find_new_mon $ws)
        flip $mon $correct_mon # comment out if don't want flip functionality -B2
        sleep 0.2
        echo -e "\nCurrent:"
        get_current_orientation # refresh after move
        changed=1
        break # Exit for loop to re-check from start
      fi
    done
  done
  move_mouse
}

# curretly wanting to add: workspace dupe fix eg mon1 4 and mon2 6 both from same group
# what i use because yk development
function dev() {
  echo "Current:"
  get_current_orientation
  echo
  echo "Correct:"
  get_correct_orientation
  echo

  local changed=1
  while ((changed)); do
    changed=0
    for mon in "${!current_orientation[@]}"; do
      local ws="${current_orientation[$mon]}"
      if ! workspace_good "$mon" "$ws"; then
        move_workspace "$mon" "$ws"
        echo -e "\nFlip Workspace:"
        correct_mon=$(find_new_mon $ws)
        flip $mon $correct_mon # can enable/disable within config
        sleep 0.2
        echo -e "\nCurrent:"
        get_current_orientation # refresh after move
        changed=1
        break # Exit for loop to re-check from start
      fi
    done
  done
  correct_config_mouse # can enable/disable within config
}

function test() {
  get_current_orientation
  get_correct_orientation

  for mon in "${!current_orientation[@]}"; do
    local ws="${current_orientation[$mon]}"
    correct_mon=$(find_new_mon $ws)
    echo
    echo NEW:
    echo current $mon correct $correct_mon
  done
}

case $1 in
-c)
  get_current_orientation
  ;;
--run | -r)
  main
  ;;
--dev | -d)
  dev
  ;;
-e)
  echo "Current:"
  get_current_orientation
  echo
  echo "Correct:"
  get_correct_orientation
  echo
  compare_orientations
  ;;
--check | -s)
  echo "Current:"
  get_current_orientation
  echo
  echo "Correct:"
  get_correct_orientation
  check_workspace_locations
  ;;
-t)
  test
  ;;
*)
  show_help
  ;;
esac
