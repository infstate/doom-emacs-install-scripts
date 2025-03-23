#!/bin/bash
sudo apt-get update
sudo apt-get install -y git
sudo apt-get install -y emacs
sudo apt-get install -y ripgrep fd-find
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
~/.config/emacs/bin/doom install