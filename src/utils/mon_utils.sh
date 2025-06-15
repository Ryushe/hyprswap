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
#finish 
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
