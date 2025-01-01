#!/bin/sh -e

RC='\033[0m'  # From Linutil
RED='\033[31m'
YELLOW='\033[33m'
CYAN='\033[36m'
GREEN='\033[32m'

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
	printf "%b\n" "${RED} Removing Previous Emacs Installation! Continue? ${RC}"
	while true; do
		read -p "[doom-emacs-install-scripts] Remove Previous Emacs with Apt Remove? (Needed to Continue) " yn
	    case $yn in
		[Yy]* ) echo "Continuing with installation"; break;;
		[Nn]* ) exit;;
		* ) echo "Please answer yes or no.";;
	    esac
	done

	sudo apt remove emacs
	sudo apt autoremove
	printf "%b\n" "${CYAN} Installing Dependcies and Libraries for compilation ${RC}"
	sudo apt-get update
	sudo apt-get install git wget curl autoconf libtool texinfo automake
	sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
	sudo sed -i 's/^Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources
	printf "%b\n" "${CYAN} Adding Deb Src to Ubuntu Sources ${RC}"
	sudo apt-get update
	printf "%b\n" "${CYAN} Running apt-get build-dep ${RC}"
	sudo apt-get build-dep emacs
	mkdir -p build
	cd build
	printf "%b\n" "${CYAN} Created build directory! Use ls after installation to see it! ${RC}"
	printf "%b\n" "${CYAN} Fetching Emacs 29.4 source tarball ${RC}"
	mkdir -p build/
	cd build/
	wget https://gnu.mirror.constant.com/emacs/emacs-29.4.tar.xz # Update to latest emacs version
	tar -xvf emacs-29.4.tar.xz
	rm emacs-29.4.tar.xz
	mv emacs-29.4/ emacs/
	printf "%b\n" "${CYAN} Installing additional depencies ${RC}"
	sudo apt-get install gcc-13 libgccjit0 libgccjit-13-dev -y # Update to latest Gcc Version
	sudo apt-get install libjansson4 libjansson-dev -y # If you want fast JSON support (Or comment out if not)

	export CC="gcc-13" # Update to latest gcc version (on your system)
	cd emacs
	printf "%b\n" "${YELLOW} Attempting to build.... ${RC}"

	./autogen.sh
	printf "%b\n" "${YELLOW} Configuring with flags... ${RC}"
	./configure --with-json --with-native-compilation # Remove --with-json if you do not want JSON support)
	# Change these configure flags if you want. (For example: --without-compress-install, --with-json --with-mailutils)
	printf "%b\n" "${YELLOW} Starting Make process ${RC}"

	make
	sudo make install
	printf "%b\n" "${CYAN} Installing ripgrep and fd ${RC}"
	sudo apt-get update
	sudo apt-get install ripgrep fd-find
	printf "%b\n" "${GREEN} Finished building! Emacs 29.4 + Nativecomp has finished building and is installed! ${RC}"

}

install_package() {
    case $DISTRO in
        ubuntu)
	    printf "%b\n" "${YELLOW}Detected Ubuntu: Compiling from scratch! ${RC}"
	    compile_from_scratch_ubuntu	
            ;;
        fedora)
	    printf "%b\n" "${YELLOW}Detected Fedora ${RC}"
            sudo dnf install git ripgrep
            sudo dnf copr enable deathwish/emacs-pgtk-nativecomp
            sudo dnf install emacs
            ;;
        arch)
	    printf "%b\n" "${YELLOW}Detected Arch Linux ${RC}"
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
while true; do
    read -p "[doom-emacs-install-scripts] Install Doom-Emacs on your system? " yn
    case $yn in
        [Yy]* ) echo "Continuing with installation"; break;;
        [Nn]* ) exit 1;;
        * ) echo "Please answer yes or no.";;
    esac
done

install_package

printf "%b\n" "${GREEN}Cloning Doom-Emacs...${RC}"
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
printf "%b\n" "${GREEN}Doom Emacs is now installed! :) ${RC}"
printf "%b\n" "${GREEN} Added doom binary to path ${RC}"

echo "Please restart your shell or source the configuration file to apply changes."
