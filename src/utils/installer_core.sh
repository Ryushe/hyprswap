#!/bin/bash
# currently:
# setup.sh
# init.sh
print_config() {
  echo "#########################"
  echo "##   hyprswap config   ##"
  echo "#########################"
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

show_monitors() {
  i=1
  for mon in ${mons[@]}; do
    echo "\$mon$i = $mon"
    i=$((i + 1))
  done
}

make_monitor_list() {
  # have to declare -A monitor_list
  i=1
  for mon in ${mons[@]}; do
    monitor_list[$mon]="mon$i"
    i=$((i + 1))
  done
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
        echo "workspace=$r,monitor:\$${monitor_list[$mon]},default:true"
      else
        echo "workspace=$r,monitor:\$${monitor_list[$mon]}"
      fi
    done
  done
}

generate_hyprland_config() {
  key=""
  local hyprswap_cmd="bind = \$mainMod, $key, exec, hyprswap"
  echo -e "Making hyprland config"
  echo

  # overwrite_config # check if user wants to overwrite cfg  # uncoment if want config file made again
  # prompts user how many want
  num_of_workspaces

  echo "outputing hyprland config..."
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

    make_monitor_list
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
