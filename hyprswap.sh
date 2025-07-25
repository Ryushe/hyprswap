#!/usr/bin/bash
main_config="$HOME/.config/hypr/hyprswap.conf"
dir="/usr/share/hyprswap-git"
[ -d "$HOME/.local/share/hyprswap" ] && dir="$HOME/.local/share/hyprswap"

function show_help() {
  echo "Help Menu:"
  echo "  -l | --left        Swap workspaces to the left"
  echo "  -r | --right       Swap workspaces to the right"
  echo "  -c | --correct     Correct current workspaces"
  echo "  -g | --generate    Generate hyprsome's config for hyprland.conf"
  echo "  -v | --verbose     output in verbose mode"
  echo "  -h | --help        help menu"
}

run_verbose() {
  if $verbose_flag; then
    "$@"
  else
    "$@" >/dev/null 2>&1
  fi
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
  if [[ -n "${cmd:-}" ]]; then
    run_verbose eval "$cmd"
  fi

}

function no_params_exit() {
  if [[ "$1" == "" ]]; then
    show_help
    exit 0
  fi
}

# not sure if good
function first_run() {
  if [[ ! -f "$main_config" ]]; then
    eval "$dir/src/utils/init.sh"
    exit 1
  fi
}

function source_config() {
  if [[ -f $main_config ]]; then
    run_verbose echo "Using main config"
    source "$main_config"
  else
    run_verbose echo "Using default config"
    source "$dir/assets/default_config.conf"
  fi
}

left_flag=false
right_flag=false
correct_flag=false
verbose_flag=false

if [[ $# -eq 0 ]]; then
  show_help
  exit 0
fi

## start of app
first_run # exits if first run
source_config

getopt -T
if [ "$?" != 4 ]; then
  echo 2>&1 "Wrong version of 'getopt' detected, exiting..."
  exit 1
fi
set -o errexit -o noclobber -o nounset -o pipefail
# note for perams, if peram needs arg set it with : after eg l: && left:
params="$(getopt -o lrcvhg -l left,right,correct,verbose,help,generate --name "$0" -- "$@")"
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
  -g | --generate)
    echo "generating config"
    eval $dir/setup.sh --generate
    shift
    ;;
  -v | --verbose)
    echo "verbose"
    verbose_flag=true
    shift
    ;;
  -h | --help)
    show_help
    exit 1
    ;;
  --)
    shift
    break
    ;;
  *)
    show_help
    exit 1
    ;;
  esac
done

check_flag_conflicts
run_flag_scripts
