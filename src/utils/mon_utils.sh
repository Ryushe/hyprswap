#!/bin/sh

get_mons() {
  IFS=$'\n' read -r -d '' -a mons < <(hyprctl monitors | grep Monitor | awk '{print $2}' && printf '\0')
  #mons=($(hyprctl monitors | grep Monitor | awk '{print $2}'))
}

list_mons() {
  get_mons
  for i in "${!mons[@]}"; do
    monitor="${mons[$i]}"
    echo $monitor
  done
}

get_monitor_pos() {
  IFS=$'\n' read -r -d '' -a pos < <(hyprctl monitors | grep " at " | awk '{print $3}' && printf '\0')
}

get_vertical_mons() {
mapfile -t vertical_mons < <(awk -F',' '
  /^\s*monitor=.*transform/ {
    sub(/^monitor=/, "", $1)
    for (i=1; i<=NF; i++) {
      if ($i == "transform" && $(i+1) ~ /^[1357]$/) {
        print $1
      }
    }
  }
' "$HOME/.config/hypr/hyprland.conf")

}

get_hypr_mons() {
  # reads from hyprland.conf to get monitor config (full section)
  mapfile -t hypr_mons < <(grep -E '^\s*monitor=' ~/.config/hypr/hyprland.conf | grep -v '^\s*#')
}

show_hypr_mons() {
  space_range=1
  for ((i = 0; i < ${#hypr_mons[@]}; i++)); do
    echo ${hypr_mons[i]} # lines from current config
    echo "workspace=${mons[i]},$space_range"
    space_range=$((space_range + num_workspaces))
  done
}
