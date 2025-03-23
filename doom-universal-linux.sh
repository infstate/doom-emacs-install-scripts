#!/bin/sh -e

detect_distro() {
    if [ -f /etc/os-release ]; then
        . `/etc/os-release`
        DISTRO=$ID
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        DISTRO=$DISTRIB_ID
    else
        DISTRO=$(uname -s)
    fi

    DISTRO=$(echo $DISTRO | tr '[:upper:]' '[:lower:]')
}

compile_from_scratch_ubuntu() { # No longer compiles from scratch since Emacs 30.1
    sudo apt-get update
    sudo apt-get install -y git
    sudo apt-get install -y emacs
    sudo apt-get install -y ripgrep fd-find
    git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
    ~/.config/emacs/bin/doom install
}

doom_macosx_installer () {
    prompt_to_install_homebrew() {
        while true; do
            read -p "[doom-emacs-install-scripts] Install Homebrew on your system and continue with installation (Y or N)? " yn
            case $yn in
                [Yy]* ) echo "Continuing with installation"; break;;
                [Nn]* ) exit;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    }

    if ! command -v brew 2>&1 >/dev/null
    then
        echo "Homebrew package manager is not installed."
        prompt_to_install_homebrew
        echo "Installing homebrew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        exit 1
    fi
    brew install git ripgrep
    brew install coreutils fd
    xcode-select --install || true
    brew tap d12frosted/emacs-plus
    brew install emacs-plus
    osascript -e 'tell application "Finder" to make alias file to posix file "/opt/homebrew/opt/emacs-plus@30/Emacs.app" at posix file "/Applications" with properties {name:"Emacs.app"}' || true

}

install_package() {
    case $DISTRO in
        ubuntu)
	    echo "Detected Ubuntu"
	    compile_from_scratch_ubuntu	
            ;;
        fedora)
	    echo "Detected Fedora"
            sudo dnf install git ripgrep rust-fd-find
            sudo dnf install emacs
            ;;
        arch)
	    echo "Detected Arch Linux"
            sudo pacman -S git ripgrep fd emacs
            ;;
        opensuse*)
            sudo zypper install git ripgrep fd emacs
            ;;
        gentoo)
            sudo emerge -a dev-vcs/git
            sudo emerge -a sys-apps/emacs
            sudo emerge -a sys-apps/ripgrep
            sudo emerge -a sys-apps/fd
            ;;
        darwin)
            echo "Macos Supported"
            doom_macosx_installer
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
echo "[doom-emacs-install-scripts] Doom Emacs is now installed! Enjoy :)"
echo "Please restart your shell or source the configuration file to apply changes."
