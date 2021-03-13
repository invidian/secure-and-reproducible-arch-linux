#!/bin/bash
set -e

pacman -Sy --needed base-devel git

export BUILD_USER="a$(uuidgen | cut -d- -f1)"

useradd $BUILD_USER

sed -i 's/^# %wheel/%wheel/g' /etc/sudoers

usermod -a -G wheel $BUILD_USER

sudo -u $BUILD_USER sh -c 'export GNUPGHOME=/tmp/ssss-${USER}/.gnupg && git clone https://aur.archlinux.org/ssss.git /tmp/ssss-${USER} && source /tmp/ssss-${USER}/PKGBUILD && for i in $validpgpkeys; do gpg --keyserver keyserver.ubuntu.com --recv-keys $i; done && cd /tmp/ssss-${USER} && makepkg -cs'
mkdir -p packages

mv /tmp/ssss-$BUILD_USER/ssss-*.pkg.tar.zst ./packages/
