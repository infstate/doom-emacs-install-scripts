#!/bin/bash
sudo apt remove emacs
sudo apt autoremove
sudo apt-get update
sudo apt-get install wget autoconf automake texinfo libtool git -y
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
sudo sed -i 's/^Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources
sudo apt-get update
sudo apt-get build-dep emacs
sudo apt-get install libncurses5-dev libgnutls-dev librsvg2-dev libxpm-dev libjpeg62-dev libtiff-dev libgif-dev libqt4-dev libgtk-3-dev -y
mkdir -p build
cd build
wget https://gnu.mirror.constant.com/emacs/emacs-29.4.tar.xz
tar -xvf emacs-29.4.tar.xz
rm emacs-29.4.tar.xz
mv emacs-29.4/ emacs/
sudo apt-get install gcc-13 libgccjit0 libgccjit-13-dev
sudo apt-get install libjansson4 libjansson-dev
export CC="gcc-13"
cd emacs
./autogen.sh
./configure --without-compress-install --with-native-compilation --with-json --with-mailutils
make
sudo make install

sudo apt-get install ripgrep fd-find

git clone https://github.com/hlissner/doom-emacs ~/.emacs.d
~/.emacs.d/bin/doom install

echo 'export PATH="$HOME/.emacs.d/bin:$PATH"' >> ~/.bashrc


