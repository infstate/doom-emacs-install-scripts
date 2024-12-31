#!/bin/bash

detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        DISTRO=$DISTRIB_ID
    else
        DISTRO=$(uname -s)
    fi

    DISTRO=$(echo $DISTRO | tr '[:upper:]' '[:lower:]')
}

compile_from_scratch_ubuntu() {
	sudo apt remove emacs
	sudo apt autoremove
	sudo apt-get update
	sudo apt-get install git wget curl autoconf libtool texinfo automake
	sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
	sudo sed -i 's/^Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources
	sudo apt-get update
	sudo apt-get build-dep emacs
	mkdir -p build
	cd build
	wget https://gnu.mirror.constant.com/emacs/emacs-29.4.tar.xz # Update to latest emacs version
	tar -xvf emacs-29.4.tar.xz
	rm emacs-29.4.tar.xz
	mv emacs-29.4/ emacs/
	sudo apt-get install gcc-13 libgccjit0 libgccjit-13-dev -y # Update to latest Gcc Version
	sudo apt-get install libjansson4 libjansson-dev -y # If you want fast JSON support (Or comment out if not)

	export CC="gcc-13" # Update to latest gcc version (on your system)
	cd emacs
	./autogen.sh
	./configure --with-json --with-native-compilation # Remove --with-json if you do not want JSON support)
	# Change these configure flags if you want. (For example: --without-compress-install, --with-json --with-mailutils)
	make
	sudo make install
	sudo apt-get update
	sudo apt-get install ripgrep fd-find
}

install_package() {
    case $DISTRO in
        ubuntu)
	    compile_from_scratch_ubuntu	
            ;;
        fedora)
            sudo dnf install git ripgrep
            sudo dnf copr enable deathwish/emacs-pgtk-nativecomp
            sudo dnf install emacs
            ;;
        arch)
            sudo pacman -S git rip-grep fd emacs-nativecomp
            ;;
        opensuse*)
            echo "No Opensuse support for script right now."
            ;;
        gentoo)
            echo "No Gentoo support for script right now."
            ;;
        *)
            echo "Unsupported distribution: $DISTRO"
            exit 1
            ;;
    esac
}

# Detect the distribution
detect_distro

echo "Detected distribution: $DISTRO"

install_package

git clone https://github.com/hlissner/doom-emacs ~/.emacs.d
~/.emacs.d/bin/doom install

# Define the line to be added
export_line='export PATH="$HOME/.emacs.d/bin:$PATH"'

# Function to append the line to a file if it doesn't already exist
append_if_not_exists() {
    if ! grep -qF "$export_line" "$1"; then
        echo "$export_line" >> "$1"
        echo "Added to $1"
    else
        echo "Line already exists in $1"
    fi
}

# Detect the current shell
current_shell=$(basename "$SHELL")

case "$current_shell" in
    bash)
        append_if_not_exists "$HOME/.bashrc"
        ;;
    zsh)
        append_if_not_exists "$HOME/.zshrc"
        ;;
    fish)
        # Fish uses a different syntax and location
        fish_config="$HOME/.config/fish/config.fish"
        fish_line='set -gx PATH "$HOME/.emacs.d/bin" $PATH'
        if ! grep -qF "$fish_line" "$fish_config"; then
            echo "$fish_line" >> "$fish_config"
            echo "Added to $fish_config"
        else
            echo "Line already exists in $fish_config"
        fi
        ;;
    *)
        # For other shells, try to add to .profile as a fallback
        append_if_not_exists "$HOME/.profile"
        echo "Warning: Unrecognized shell. Added to .profile as a fallback."
        ;;
esac

echo "Please restart your shell or source the configuration file to apply changes."

