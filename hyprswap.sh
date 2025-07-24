#!/usr/bin/bash

dir="/usr/share/hyprswap-git"
[ -d "$HOME/.local/share/hyprswap" ] && dir="$HOME/.local/share/hyprswap"

main_config="$HOME/.config/hypr/hyprswap.conf"
if [[ -f $main_config ]]; then
  source "$main_config"
else
  source "$dir/assets/default_config.conf"
fi

function show_help() {
  echo "Help Menu:"
  echo "  -l | --left        Swap workspaces to the left"
  echo "  -r | --right       Swap workspaces to the right"
  echo "  -c | --correct     Correct current workspaces"
  echo "  -v | --verbose     output in verbose mode"
}

function check_flag_conflicts() {
  if $left_flag && $right_flag; then
    echo "You can't use both left and right flag"
    echo "Exiting..."
    exit 1
  fi

  if { $left_flag && $correct_flag; } || { $right_flag && $correct_flag; }; then
    echo "You can't use the correct flag with a direction"
    echo "Exiting..."
    exit 1
  fi
}

function run_flag_scripts() {
  if $left_flag; then
    cmd="$dir/src/swap_active_workspaces.sh l"
  elif $right_flag; then
    cmd="$dir/src/swap_active_workspaces.sh r"
  elif $correct_flag; then # add -r (for dev and normal) or just do mouse
    cmd="$dir/src/correct_workspaces.sh -d"
  fi

  # Only run if a command was set
  if [[ -n "${cmd:-}" ]]; then
    if $verbose_flag; then
      eval "$cmd"
    else
      eval "$cmd" >/dev/null 2>&1
    fi
  fi

}

function no_params_exit() {
  if [[ $# -eq 0 ]]; then
    show_help
    exit 0
  fi
}

# not sure if good
function first_run() {
  if [[ ! -f "$HOME/.config/hyprswap.conf" ]]; then
    eval "$dir/src/utils/init.sh"
    exit 1
  fi
}

left_flag=false
right_flag=false
correct_flag=false
verbose_flag=false

## start of app
first_run

no_params_exit

getopt -T
if [ "$?" != 4 ]; then
  echo 2>&1 "Wrong version of 'getopt' detected, exiting..."
  exit 1
fi
set -o errexit -o noclobber -o nounset -o pipefail
# note for perams, if peram needs arg set it with : after eg l: && left:
params="$(getopt -o lrcvhn -l left,right,correct,verbose,help,no-mouse --name "$0" -- "$@")"
eval set -- "$params"

# note: if want args access it with $2 and put shift 2
while true; do
  case "$1" in
  -l | --left)
    echo left
    left_flag=true
    shift
    ;;
  -r | --right)
    echo "right"
    right_flag=true
    shift
    ;;
  -c | --correct)
    echo "correct"
    correct_flag=true
    shift
    ;;
  -v | --verbose)
    echo "verbose"
    verbose_flag=true
    shift
    ;;
  -h | --help)
    show_help
    shift
    ;;
  -n | --no-mouse) # just implement things like this within the config
    echo "no mouse"
    shift
    ;;
  --)
    shift
    break
    ;;
  *)
    echo "Not implemented: $1" >&2
    exit 1
    ;;
  esac
done

check_flag_conflicts
run_flag_scripts
