# hyprswap
Hyprswap allows users to move monitors around more freely, breaking the limits of whats possible with the wayland compositor. 

# installation
1. run `./setup.sh`
2. copy outputted config from `setup.sh` into hyprland.conf (replacing old monitor and workspace conf)
  - NOTE: adjust resolutions, positions, and hrtz to desired settings after pasting into hyprland.conf
3. 

# config 
## installation script
If you used then installation script you should have a really amazing start for your hyprland.conf file

Now, copy the outputted result into you hyprland.conf file replacing:
- monitor config
- workspace config
- workspace keybind config

## manual
Install rust with `sudo pacman -S rust`  

Install Hyprsome with `cargo install hyprsome`

### workspaces / hyprsome
Add workspaces to your monitor section in your hyprland.conf file
```
example dual monitor setup:

monitor=DP-1,1920x1080@60,0x0,1.33
monitor=DP-1,transform,1
workspace=DP-1,1 <--
monitor=HDMI-A-1,3440x1440@100,813x0,1
workspace=HDMI-A-1,11 <--
```

The number at the end of the workspace line will determine how many workspaces are given to each monitor.  

Eg: 1 - 11 = 10 workspaces per monitor

Bind the workspaces to your monitors:  
```
  workspace=1,monitor:DP-1
  workspace=2,monitor:DP-1
  workspace=3,monitor:DP-1
  workspace=4,monitor:DP-1
  workspace=5,monitor:DP-1

  workspace=11,monitor:HDMI-A-1
  workspace=12,monitor:HDMI-A-1
  workspace=13,monitor:HDMI-A-1
  workspace=14,monitor:HDMI-A-1
  workspace=15,monitor:HDMI-A-1
```

Find out more about configuring hyprsome  [here](https://github.com/sopa0/hyprsome).

### keybinds
Set hotkeys to call hyprsome:
```
bind=SUPER,1,exec,hyprsome workspace 1
bind=SUPER,2,exec,hyprsome workspace 2
bind=SUPER,3,exec,hyprsome workspace 3
bind=SUPER,4,exec,hyprsome workspace 4
bind=SUPER,5,exec,hyprsome workspace 5

bind=SUPERSHIFT,1,exec,hyprsome move 1
bind=SUPERSHIFT,2,exec,hyprsome move 2
bind=SUPERSHIFT,3,exec,hyprsome move 3
bind=SUPERSHIFT,4,exec,hyprsome move 4
bind=SUPERSHIFT,5,exec,hyprsome move 5
```

Set hyprswap keybinds:
```
bind = $mainMod, x, exec, $HOME/hyprswap/src/swap_active_workspaces.sh l
bind = $mainMod, c, exec, $HOME/hyprswap/src/swap_active_workspaces.sh r
bind = $mainMod, R, exec, $HOME/hyprswap/src/correct_workspaces.sh -d
```

Thats it!!


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

# Credits 
[Hyprsome](https://github.com/sopa0/hyprsome)
