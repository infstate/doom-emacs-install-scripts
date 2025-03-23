#!/bin/bash

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

while true; do
    read -p "[doom-emacs-install-scripts] Install Doom-Emacs on your system? " yn
    case $yn in
        [Yy]* ) echo "Continuing with installation"; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

brew install git ripgrep
brew install coreutils fd
xcode-select --install

brew tap d12frosted/emacs-plus
brew install emacs-plus
osascript -e 'tell application "Finder" to make alias file to posix file "/opt/homebrew/opt/emacs-plus@30/Emacs.app" at posix file "/Applications" with properties {name:"Emacs.app"}'

git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
~/.config/emacs/bin/doom install