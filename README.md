# hyprswap
Hyprswap is a "hyprland" plugin built utilizing hyprsome. Allowing, users to move their monitors around with ease. 

What does this mean exactly? It allows for the movement of your second monitor to your main monitor and then correct their locations with ease

Still confused? Check out the example below: 

https://github.com/user-attachments/assets/c27eb2b4-be3c-4441-be72-891166c81516


> [!NOTE]
> currently only supports up to 3 monitors

> [!IMPORTANT]
> Before changing the monitor workspace IF swapped run `hyprswap --correct` or set manually, this is necessary due to how Hyprland manages the monitors  
> If you forget checkout the [fix](#issues-and-fixes)   

## installation

### installation script
NOTE: Pulls monitor config from hyprland.conf 
1. `git clone https://github.com/Ryushe/hyprswap.git`
2. `cd hyprswap`
3. run `./setup.sh -a` 
- Runs installer and generates a hyprland config based on your current monitor setup in hyprland.conf
4. copy generated hyprland config into `hyprland.conf`
  - Or create a file and source it 
5. remove old workspace keybinds (switching to workspace, and moving windows) 
  - leaving can cause issues


Default keybinds:
- win+x = move focused mon left
- win+c = move focused mon right
- win+r = move the workspaces back to their original location

### Configs
Hyprswap config is found at `$HOME/.config/hypr/hyprswap.conf`

Current Features: (true or false)
- Monitor Flip - change orientation to match the monitor eg: horizontal -> vertical(dwindle)
- Center Mouse
  - When correcting monitor positions
  - All the time
- Double click reset - correct monitor positions by clicking same swap direction twice
  - Adjustable wait time 

### manual installation
1. `git clone https://github.com/Ryushe/hyprswap.git`
2. `cd hyprswap`
3. Install rust with `sudo pacman -S rust`  
4. Install Hyprsome with `cargo install hyprsome`
5. `
mkdir -p ~/.local/share/hyprswap && cp -rT --remove-destination ./ ~/.local/bin/hyprswap/hyprswap/`
6. `ln -s  ~/.local/bin/hyprswap/hyprswap/hyprswap.sh /usr/bin/hyprswap`

#### workspaces / hyprsome
7. Add workspaces to your monitor section in your hyprland.conf file
```
example dual monitor setup:

monitor=DP-1,1920x1080@60,0x0,1.33
monitor=DP-1,transform,1
workspace=DP-1,1 #<--
monitor=HDMI-A-1,3440x1440@100,813x0,1
workspace=HDMI-A-1,11 #<--
```

The number at the end of the workspace line will determine how many workspaces are given to each monitor.  

Eg: 1 - 11 = 10 workspaces per monitor

8. Bind the workspaces to your monitors:  
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
9. Set hotkeys to call hyprsome:
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
# hyprswap keybinds:
bind = $mainMod, x, exec, hyprswap --left
bind = $mainMod, c, exec, hyprswap --right
bind = $mainMod, R, exec, hyprswap --correct
```

> [!NOTE]
> Make sure to use `hyprswap --correct` / put your monitors back to the correct orientation manually before switching workspaces. If not, workspace keybinds will get messed up.

#### If swap workspaces without setting it back to the correct config 
Use your task bar (eg: waybar) to select the messed up workspace since your keybinds for that workspace will no longer work. This is a "feature", due to the limitation of the way hyprland binds monitors/workspaces.

A cool workaround:  
Add `hyprswap --correct &&` to the beginning of the workspace commands like so
```
bind=SUPER,1,exec, bash -c 'hyprswap --correct && hyprsome workspace 1'
bind=SUPERSHIFT,1,exec, bash -c 'hyprswap --correct && hyprsome move 1'
```

## Credits 
[Hyprsome](https://github.com/sopa0/hyprsome)
