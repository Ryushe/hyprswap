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
  cd "$srcdir/$pkgname"
  git describe --tags | sed 's/^v//;s/-/./g'
}

build() {
  cd "$srcdir/$pkgname"
  cargo install --path . --root "$pkgdir/usr"
}

package() {
  cd "$srcdir/$pkgname"
  install -Dm755 hyprswap.sh "$pkgdir/usr/bin/hyprswap"
  install -d "$pkgdir/usr/lib/$pkgname"
  cp -a . "$pkgdir/usr/lib/$pkgname"
}
