#!/bin/sh -e

RC='\033[0m'  # From Linutil
RED='\033[31m'
YELLOW='\033[33m'
CYAN='\033[36m'
GREEN='\033[32m'

# Detect interactive mode
is_interactive() {
    # Check if PS1 exists and is not empty, indicating interactive shell
    [ -n "$PS1" ]
}

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
    if is_interactive; then
        printf "%b\n" "${RED} Removing Previous Emacs Installation! Continue? ${RC}"
        while true; do
            read -p "[doom-emacs-install-scripts] Remove Previous Emacs with Apt Remove? (Needed to Continue) " yn
            case $yn in
                [Yy]* ) echo "Continuing with installation"; break;;
                [Nn]* ) exit;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    fi

    sudo apt remove -y emacs
    sudo apt autoremove -y
    printf "%b\n" "${CYAN} Installing Dependencies and Libraries for compilation ${RC}"
    sudo apt-get update
    sudo apt-get install -y git wget curl autoconf libtool texinfo automake
    sudo apt-get install -y apt-transport-https ca-certificates gnupg-agent software-properties-common
    sudo sed -i 's/^Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources || true
    printf "%b\n" "${CYAN} Adding Deb Src to Ubuntu Sources ${RC}"
    sudo apt-get update
    printf "%b\n" "${CYAN} Running apt-get build-dep ${RC}"
    sudo apt-get build-dep -y emacs
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
    printf "%b\n" "${CYAN} Installing additional dependencies ${RC}"
    sudo apt-get install -y gcc-13 libgccjit0 libgccjit-13-dev
    sudo apt-get install -y libjansson4 libjansson-dev

    export CC="gcc-13"
    cd emacs
    printf "%b\n" "${YELLOW} Attempting to build.... ${RC}"

    ./autogen.sh
    printf "%b\n" "${YELLOW} Configuring with flags... ${RC}"
    ./configure --with-json --with-native-compilation
    printf "%b\n" "${YELLOW} Starting Make process ${RC}"

    make
    sudo make install
    printf "%b\n" "${CYAN} Installing ripgrep and fd ${RC}"
    sudo apt-get update
    sudo apt-get install -y ripgrep fd-find
    printf "%b\n" "${GREEN} Finished building! Emacs 29.4 + Nativecomp has finished building and is installed! ${RC}"
}

install_package() {
    case $DISTRO in
        ubuntu)
            printf "%b\n" "${YELLOW}Detected Ubuntu: Compiling from scratch! ${RC}"
            compile_from_scratch_ubuntu
            ;;
        # ... other distros
    esac
}

# Detect the distribution
detect_distro

if is_interactive; then
    echo "Detected distribution: $DISTRO"
    while true; do
        read -p "[doom-emacs-install-scripts] Install Doom-Emacs on your system? " yn
        case $yn in
            [Yy]* ) echo "Continuing with installation"; break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done
fi

install_package

printf "%b\n" "${GREEN}Cloning Doom-Emacs...${RC}"
git clone https://github.com/hlissner/doom-emacs ~/.emacs.d
~/.emacs.d/bin/doom install

# Set up PATH
export_line='export PATH="$HOME/.emacs.d/bin:$PATH"'
append_if_not_exists() {
    if ! grep -qF "$export_line" "$1"; then
        echo "$export_line" >> "$1"
        echo "Added to $1"
    else
        echo "Line already exists in $1"
    fi
}

current_shell=$(basename "$SHELL")

case "$current_shell" in
    bash)
        append_if_not_exists "$HOME/.bashrc"
        ;;
    zsh)
        append_if_not_exists "$HOME/.zshrc"
        ;;
    fish)
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
        append_if_not_exists "$HOME/.profile"
        echo "Warning: Unrecognized shell. Added to .profile as a fallback."
        ;;
esac

printf "%b\n" "${GREEN}Doom Emacs is now installed! :) ${RC}"
printf "%b\n" "${GREEN} Added doom binary to path ${RC}"
echo "Please restart your shell or source the configuration file to apply changes."
