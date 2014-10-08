#!/usr/bin/env bash
#
# Written by: crossroads1112
# Purpose: Automate post-install setup of Arch Linux
#
#
#
#
##############################
dir=~/.dotfiles # dotfiles directory
olddir=~/.dotfiles_old # old dotfiles backup directory
files="zshrc vimrc tmux.conf vimperatorrc" # list of files/folders to symlink in homedir
bold=$(tput bold)
normal=$(tput sgr0)
bold(){
    echo "${bold}$@${normal}"
}
pkg(){
    bold "Do you want to install your previous packages?"
    read answer
    case $answer in 
        ""|[Yy]|[Yy][Ee][Ss]) 
            if grep -q "#\[multilib\]" /etc/pacman.conf; then
                bold "Activating multilib repo... "
                multilibline=$(grep -n "#\[multilib\]" /etc/pacman.conf | cut -d ':' -f1)
                sudo sed -i "$multilibline,$(( $multilibline + 1 ))s/#//" /etc/pacman.conf && echo "Done" || { echo "Failed"; exit 1} # Uncomments multilib repo in /etc/pacman.conf
            fi
            bold "Adding infinality and pipelight repos..."
            {
            echo -e "[infinality-bundle]\nServer = http://bohoomil.com/repo/$arch\n\n[infinality-bundle-multilib]\nServer = http://bohoomil.com/repo/multilib/$arch\n\n[pipelight]\nServer = http://repos.fds-team.de/stable/arch/$arch" | sudo tee -a /etc/pacman.conf # Adds infinality, infinality-multilib and pipelight repos to /etc/pacman.conf
            for key in 962DDE58 E49CC0415DC2D5CA; do
                sudo pacman-key -r $key
                sudo pacman-key --lsign $key
            done
            } && bold "Done" || { bold "Failed; exit 1; }"
            sudo pacman -Syy --needed $(comm -12 <(pacman -Slq|sort) <(sort $dir/pacman_pkgs)) || exit 1
            ;;
        [Nn]|[Nn][Oo]) exit 0
            ;;
        *) bold "Sorry, that is not an acceptable response"
            pkg
            ;;
    esac
}
aur(){
    bold "Do you want to install AUR packages as well? [y/N]"
    read answer
    case $answer in 
        [Yy]|[Yy][Ee][Ss]) 
            if [[ ! -f /usr/bin/yaourt ]]; then
                bold "Installing yaourt"
                {
                cd
                curl -O https://aur.archlinux.org/packages/pa/package-query/package-query.tar.gz
                tar zxvf package-query.tar.gz
                cd package-query
                makepkg -si
                cd ..
                curl -O https://aur.archlinux.org/packages/ya/yaourt/yaourt.tar.gz
                tar zxvf yaourt.tar.gz
                cd yaourt
                makepkg -si
                cd ..
                rm  -rf ./package-query.tar.gz ./yaourt.tar.gz ./package-query ./yaourt
                } && bold "Done" || { bold "Failed"; exit 1; }
            fi
            yaourt -S --needed $(cat $dir/aur_pkgs)
            ;;
        ""|[Nn]|[Nn][Oo])  exit 0 
            ;;
        *) bold "Sorry, that is not an acceptable response"
            aur
            ;;
    esac
}

# create dotfiles_old in homedir
bold "Creating $olddir for backup of any existing dotfiles in ~ ..."
mkdir -p $olddir
bold "Done"

# change to the dotfiles directory
bold "Changing to the $dir directory ..."
cd $dir
bold "Done"

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks from the homedir to any files in the ~/dotfiles directory specified in $files
for file in $files; do
    bold "Moving any existing dotfiles from ~ to $olddir"
    mv ~/.$file ~/.dotfiles_old/
    bold "Creating symlink to $file in home directory."
    ln -s $dir/$file ~/.$file
done
#Extra stuff
bold "Setting up mpd for user $(whoami)... "
{
mkdir -p ~/.config/mpd/playlists
touch ~/.config/mpd/{database,log,pid,state,sticker,sql}
printf "db_file            \"~/.config/mpd/database\"\nlog_file           \"~/.config/mpd/log\"\n\nmusic_directory    \"~/Music\"\nplaylist_directory \"~/.config/mpd/playlists\"\npid_file           \"~/.config/mpd/pid\"\nstate_file         \"~/.config/mpd/state\"\nsticker_file       \"~/.config/mpd/sticker.sql\"" > ~/.config/mpd/mpd.conf
} && bold "Done" || bold "Failed"

bold "Setting up ranger... "
{
ranger --copy-config=all > /dev/null
rm ~/.config/ranger/commands.py
ln -s $dir/commands.py ~/.config/ranger/commands.py
} && bold "Done" || bold "Failed"

pkg
aur
