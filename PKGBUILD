pkgname=hyprswap-git
pkgver=1.0.0
pkgrel=1
pkgdesc="Workspace swapper for Hyprland"
arch=('x86_64')
url="https://github.com/Ryushe/hyprswap"
depends=('hyprsome-git')
makedepends=('git')
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
}

package() {
  cd "$srcdir/$pkgname"
  install -Dm755 "target/release/hyprswap" "$pkgdir/usr/bin/hyprswap"
}
