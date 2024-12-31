#!/bin/bash
sudo apt remove emacs
sudo apt autoremove
sudo apt-get update
sudo sed -i 's/^Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources
sudo apt-get update
sudo apt-get build-dep emacs
mkdir -p build
cd build
wget https://gnu.mirror.constant.com/emacs/emacs-29.4.tar.xz # Update to latest emacs version
tar -xvf emacs-29.4.tar.xz
rm emacs-29.4.tar.xz
mv emacs-29.4/ emacs/
sudo apt-get install gcc-13 libgccjit0 libgccjit-13-dev # Update to latest Gcc Version
sudo apt-get install libjansson4 libjansson-dev # If you want fast JSON support (Or comment out if not)

export CC="gcc-13" # Update to latest gcc version (on your system)
cd emacs
./autogen.sh
./configure --with-json --with-native-compilation # Remove --with-json if you do not want JSON support)
# Change these configure flags if you want. (For example: --without-compress-install, --with-json --with-mailutils)
make
sudo make install
sudo apt-get install ripgrep fd-find
git clone https://github.com/hlissner/doom-emacs ~/.emacs.d
~/.emacs.d/bin/doom install
echo 'export PATH="$HOME/.emacs.d/bin:$PATH"' >> ~/.bashrc # For bash only
