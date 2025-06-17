# hyprswap
Hyprswap allows users to move monitors around more freely, breaking the limits of whats possible with the wayland compositor. 


## installation

### installation script
1. run `sudo ./setup.sh` - installs the app
1. run `./setup.sh` - generate the example config using your current monitor settings
1. copy outputted config into hyprland.conf (replacing old monitor and workspace conf)
  - NOTE: adjust resolutions, positions, and hrtz to desired settings after pasting into hyprland.conf
1. adjust to the preset configs to your liking

Now, copy the outputted result into you hyprland.conf file replacing:
- monitor config
- workspace config
- workspace keybind config

### manual
Install rust with `sudo pacman -S rust`  

Install Hyprsome with `cargo install hyprsome`

#### workspaces / hyprsome
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

#### keybinds
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

## usage
Set hyprswap keybinds:
```
bind = $mainMod, x, exec, hyprswap --left
bind = $mainMod, c, exec, hypswap --right
bind = $mainMod, R, exec, hyprswap --correct
```

Thats it!!


## Credits 
[Hyprsome](https://github.com/sopa0/hyprsome)
