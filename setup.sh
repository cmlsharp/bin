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
files="zshrc vimrc tmux.conf vimperatorrc zsh_plugins mailcap mutt muttrc" # list of files/folders to symlink in homedir
PS3="Please enter a number: "
dotfilesrepo="crossroads1112/dotfiles"
bold(){
    echo "$(tput bold)$@$(tput sgr0)"
}
goback(){
     read -p "All done. Press [ENTER] to go back to the main menu"
     menu
}
pkg(){
    if grep -q "#\[multilib\]" /etc/pacman.conf; then
        bold "Activating multilib repo... "
        multilibline=$(grep -n "#\[multilib\]" /etc/pacman.conf | cut -d ':' -f1)
        sudo sed -i "$multilibline,$(( $multilibline + 1 ))s/#//" /etc/pacman.conf # Uncomments multilib repo in /etc/pacman.conf
    fi
    bold "Adding infinality, pipelight repos and blackarch..."
    curl -s http://blackarch.org/strap.sh | sudo sh
    for key in 962DDE58 E49CC0415DC2D5CA; do
        sudo pacman-key -r $key
        sudo pacman-key -f $key
        sudo pacman-key --lsign $key
    done

    
    echo -e "[infinality-bundle]\nServer = http://bohoomil.com/repo/\$arch\n\n[infinality-bundle-multilib]\nServer = http://bohoomil.com/repo/multilib/\$arch\n\n[pipelight]\nServer = http://repos.fds-team.de/stable/arch/\$arch\n[blackarch]\nServer = https://http://mirror.oss.maxcdn.com/blackarch/\$repo/os/\$arch" | sudo tee -a /etc/pacman.conf # Adds infinality, infinality-multilib and pipelight repos to /etc/pacman.conf


    sudo pacman -Syy --needed $(comm -12 <(pacman -Slq|sort) <(sort $dir/pacman_pkgs))
    goback
}

aur(){
    if [[ ! -f /usr/bin/pacaur ]]; then
        bold "Installing pacaur"
     
        cd
        curl -O https://aur.archlinux.org/packages/co/cower/cower.tar.gz
        tar zxvf cower.tar.gz
        cd cower 
        makepkg -si
        cd ..
        curl -O https://aur.archlinux.org/packages/pa/pacaur/pacaur.tar.gz
        tar zxvf pacaur.tar.gz
        cd pacaur
        makepkg -si
        cd ..
        rm  -rf ./cower.tar.gz ./pacaur.tar.gz ./cower ./pacaur
        
    fi
    pacaur -S --needed $(cat $dir/aur_pkgs)
    goback
}
configs(){
    if [[ ! -d $dir || ! -d $dir/.git ]]; then
        bold "Either dotfiles directory does not exist or there is no git repo there. Moving to ${dir}.bak"
        mv $dir ${dir}.bak
        mkdir -p $dir
        cd $dir
        bold "Setting up git repo"
        git init
        git remote add origin-https https://github.com/$dotfilesrepo
        git remote add origin git@github.com:$dotfilesrepo 
        git pull origin-https master
    fi
    bold "Decrypting mutt passwords"
    scrypt enc $dir/mypw.gpg.bfe > ~/.mypw.gpg

    bold "Creating $olddir for backup of any existing dotfiles in ~ ..."
    mkdir -p $olddir
    bold "Done"
    
    bold "Changing to the $dir directory ..."
    cd $dir
    bold "Done"
    
    for file in $files; do
        bold "Moving any existing dotfiles from ~ to $olddir"
        mv ~/.$file $olddir/
        bold "Creating symlink to $file in home directory."
        ln -s $dir/$file ~/.$file
    done
    bold "Installing NeoBundle for vim"
    [[ -d ~/.vim ]] && mv ~/.vim $olddir/
    mkdir -p ~/.vim/bundle/neobundle.vim
    git clone https://github.com/Shougo/neobundle.vim.git ~/.vim/bundle/neobundle.vim
    goback
}

music(){
    bold "Setting up mpd for user... "
    mkdir -p ~/.config/mpd/playlists
    touch ~/.config/mpd/{database,log,pid,state,sticker,sql}
    printf "db_file            \"~/.config/mpd/database\"\nlog_file           \"~/.config/mpd/log\"\n\nmusic_directory    \"~/Music\"\nplaylist_directory \"~/.config/mpd/playlists\"\npid_file           \"~/.config/mpd/pid\"\nstate_file         \"~/.config/mpd/state\"\nsticker_file       \"~/.config/mpd/sticker.sql\"" > ~/.config/mpd/mpd.conf
    echo "Done"
    goback
} 

rang(){
    bold "Setting up ranger... "
    ranger --copy-config=all > /dev/null
    rm ~/.config/ranger/commands.py
    ln -s $dir/commands.py ~/.config/ranger/commands.py
    goback
}
menu(){
    clear
    echo "What do you want to do?"
    select i in "Reinstall packages" "Reinstall AUR packages" "Get dotfiles" "Setup mpd" "Setup ranger" Quit; do
        case $i in
            "Reinstall packages") pkg
                ;;
            "Reinstall AUR packages") aur 
                ;; 
            "Get dotfiles") configs 
                ;; 
            "Setup mpd") music 
                ;; 
            "Setup ranger") rang 
                ;; 
            Quit) exit 0
                ;;
            *) echo "Sorry, that isn't an acceptable response"
                ;;
        esac
    done
}
menu
