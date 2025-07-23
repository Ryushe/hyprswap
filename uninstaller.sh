#/bin/bash

deps=("hyprsome" "rust")

check_if_user() {
  echo "checking if user:"

  if [[ ! "$EUID" -ne 0 ]]; then
    echo "You are root"
    echo "Please don't run this script as sudo user"
  fi
  echo "Continuing as user"
}

check_if_user
echo

echo "Uninstalling hyprswap"
echo

rm -rf $HOME/.local/bin/hyprswap
rm -rf $HOME/.local/share/hyprswap
app=$(find $HOME/.local/bin -maxdepth 1 -type d -name "hyprswap" -print -quit 2>/dev/null)
if [[ -n $app ]]; then
  echo "app failed to uninstall"
  echo "try running the uninstaller once more"
  exit 1
fi

echo "Hyprswap uninstalled successfully"
echo

echo "Uninstall hyprswap's dependencies?"
for i in ${deps[@]}; do
  echo "- $i"
done
echo "[y/n]"
read -r choice
choice=${choice,,}
if [[ ! $choice == "y" ]]; then
  echo "dependencies not uninstalled"
  exit 1
fi

yay -Runs hyprsome-git
echo "Uninstalled hyprsome"

pacman -Runs rust
echo "Uninstalled rust"
echo

echo "Finished uninstalling everything"
