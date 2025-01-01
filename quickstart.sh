#!/bin/sh -e
RC='\033[0m'  # From Linutil
RED='\033[31m'
YELLOW='\033[33m'
CYAN='\033[36m'
GREEN='\033[32m'
git clone https://github.com/infstate/doom-emacs-install-scripts.git
cd doom-emacs-install-scripts/
chmod +x doom-universal-linux.sh
chmod +x doom-minimal-ubuntu.sh
chmod +x doom-ubuntu.sh
printf "%b\n" "${GREEN}Enviroment setup! Now just run any of the scripts! (e.g. ./doom-universal-linux.sh) ${RC}"
