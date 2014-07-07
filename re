#! /usr/bin/env bash
echo "Your usual country? y/n"
read input
if  [[ $input == "n" ]] || [[ $input == "N" ]] ; then 
    reflector --list-countries 
    echo 'What country are you in?'
    read home
    
elif [[ ! -z "$input" ]] || [[ $input == "Y" ]] || [[ $input == "y" ]] ; then
    home="United States"
fi
sudo reflector --verbose --country "\'$home\'" -l 200 -p http --sort rate --save /etc/pacman.d/mirrorlist

echo $home
