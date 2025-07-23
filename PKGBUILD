# Jaadyn Humphries jaadynhumpries at gmail dot com
pkgname=hyprswap-git
pkgver=1.0.0
pkgrel=1
pkgdesc="Multi-Monitor Tool: A monitor 'swapper' for Hyprland utilizing hyprsome's workspaces"
arch=('x86_64')
url="https://github.com/Ryushe/hyprswap"
depends=('hyprsome-git')
makedepends=('git' 'rust')
provides=('hyprswap')
conflicts=('hyprswap')
source=("git+$url.git")
sha256sums=('SKIP')

pkgver() {
  cd "$srcdir/${pkgname%-git}"
  git describe --tags | sed 's/^v//;s/-/./g'
}

build() {
  cd "$srcdir/${pkgname%-git}"
}

package() {
  cd "$srcdir/${pkgname%-git}"
  chmod +x hyprswap.sh
  install -Dm755 hyprswap.sh "$pkgdir/usr/bin/hyprswap"
  install -d "$pkgdir/usr/lib/$pkgname"
  cp -a . "$pkgdir/usr/lib/$pkgname"
}
