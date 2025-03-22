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
    sudo apt-get update
    sudo apt-get install -y emacs
    sudo apt-get install -y ripgrep fd-find
    git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
    ~/.config/emacs/bin/doom install
}

install_package() {
    case $DISTRO in
        ubuntu)
	    printf "%b\n" "${YELLOW}Detected Ubuntu: Compiling from scratch! ${RC}"
	    compile_from_scratch_ubuntu	
            ;;
        fedora)
	    printf "%b\n" "${YELLOW}Detected Fedora ${RC}"
            sudo dnf install git ripgrep rust-fd-find
            sudo dnf install emacs
            ;;
        arch)
	    printf "%b\n" "${YELLOW}Detected Arch Linux ${RC}"
            sudo pacman -S git ripgrep fd emacs
            ;;
        opensuse*)
            sudo zypper install git ripgrep fd emacs
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
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

install_package

printf "%b\n" "${GREEN}Cloning Doom-Emacs...${RC}"
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
~/.config/emacs/bin/doom install
# Define the line to be added
export_line='export PATH="$HOME/.config/emacs/bin:$PATH"'

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
        fish_line='set -gx PATH "$HOME/.config/emacs/bin" $PATH'
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
