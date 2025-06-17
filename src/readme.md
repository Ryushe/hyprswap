# About the scripts
This section explains how the scripts work, so if you would like to use only one of them your more than welcome to!
## Swap_active_workspaces:
  - bring your 2nd/3rd monitor to you instead of you looking at it
  - enables the ability to move the workspace on another monitor left and right
  - intended use:
    - used with correct_workspaces.sh 
    - used with [hyprsome](https://github.com/sopa0/hyprsome) workspaces
  - how I use it:
    - hyprland keybinds to move workspaces left and right with focus on mouse enabled
    - move monitors where I would like and then when I am done I hit the keybind to trigger correct_workspaces.sh to move everything back
NOTE: if not using correct_workspaces.sh make sure monitors are moved back to default layout before switching workspaces on the monitor 

## Correct_workspaces.sh:
  - compares the workspaces to the monitor config within hyprland.conf and if workspaces don't match it moves the monitors back to where they're supposed to be
  - intended use:
    - used with [hyprsome](https://github.com/sopa0/hyprsome) workspaces 
    - used alongside swap_active_workspaces.sh
  - how to use:
  1. Add swap_active_workspaces and correct_workspaces.sh to hyprland.conf as keybinds
    1. move workspaces with swap_active_workspaces.sh 
    - eg `bind = $mainMod, R, exec, $HOME/dotfiles/scripts/arch/correct_workspaces.sh -r`
    - `bind = $mainMod, x, exec, $arch_scripts/swap_active_workspaces.sh l`
    - `bind = $mainMod, c, exec, $arch_scripts/swap_active_workspaces.sh r`
<!-- eventually add the url from ryushe.sh of the uploaded video example -->

## Smart_flip.sh:  
  - Makes vertical monitor windows stack, and horizontal be side by side when moved around to the other workspaces
  - A script meant to be used with swap_active_workspaces.sh
  - HOW TO ENABLE/DISABLE:
    - swapping workspaces: comment out line 24 in swap_active_workspaces.sh (should say "flip ...")
    - resetting workspaces: 
      - enable: `bind = $mainMod, c, exec, $arch_scripts/correct_workspaces.sh -d` 
      - disable: `bind = $mainMod, c, exec, $arch_scripts/correct_workspaces.sh -r` 
  - checks if the hyprland monitor is vertical by viewing hyprland.conf
  - if current monitor = horizontal && new monitor = vertical moves the 
