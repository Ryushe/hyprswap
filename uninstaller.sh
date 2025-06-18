#/bin/bash

deps=("hyprsome" "rust")

check_root() {
  echo "checking root:"

  if [[ "$EUID" -ne 0 ]]; then
    echo "You are not root"
    echo "Please re-run as root user"
    exit 1
  fi
  echo "Running as root"
}

check_root
echo

echo "Uninstalling hyprswap"
echo

rm -rf /opt/hyprswap
app=$(find /opt -maxdepth 1 -type d -name "hyprswap" -print -quit 2>/dev/null)
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

cargo uninstall hyprsome
echo "Uninstalled hyprsome"

pacman -Runs rust
echo "Uninstalled rust"
echo

echo "Finished uninstalling everything"
