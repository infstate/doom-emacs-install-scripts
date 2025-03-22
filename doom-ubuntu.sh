#!/bin/bash
# Taken from doom-minimal. No longer need to compile from scratch since Emacs 30.1
# Just here as a placeholder
sudo apt-get update
sudo apt-get install -y emacs
sudo apt-get install -y ripgrep fd-find
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
~/.config/emacs/bin/doom install