# doom-emacs-install-scripts
Simple scripts for installing Doom Emacs
> [!IMPORTANT]  
> It is recommended you view how the script works before running (don't worry it's short). View the source code.

## Usage and Runnng

Doom-universal-linux; detects your linux distro and if it is supported installed using the recomended method.
It also detects your shell and trys to add doom directory to path.

Select your script and make sure permissisons are correct with (chmod +x), then run (./doom-universal-linux.sh) (Or whatever script you chose)
                                                                                  (Run as normal user but it will ask for password)

Supported distros for universal autoinstall. (Ubuntu, Fedora, Arch)
Supported shells for universal autoinstall. (Bash, Zsh, Fish)

Default installation dir ~/.doom.d and ~/.emacs.d

## Ubuntu 24.04.1 LTS
Installing on ubuntu compiles from scratch (emacs-29.4 + nativecomp) (Extracts source in build/ dir)
Try Doom-minimal-ubuntu first, if it fails
run Doom-ubuntu.

For Ubuntu you have 3 scripts:


| Script    | Purpose |
| -------- | ------- |
| doom-minmal-ubuntu.sh | Minimal install(Without installing extra packages)    |
| doom-ubuntu.sh | Installs everything |
| doom-universal-linux.sh    | Detects distro and installs accordingly   |



# Contributing
If you find a bug make a ticket in the Issues tab or a Pull request if you have a solution.

## Part of Infinite's Code Charity 2025 Event

![CharityBanner](https://raw.githubusercontent.com/infstate/wrenchlib/refs/heads/main/docs/assets/BannerCharity.jpg)

# Join and Contribute!

