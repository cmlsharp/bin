#!/bin/bash
# This script was written to allow my sister's Mac to connect to her work's sftp server using sshfs. This requires FUSE for OSX to work
clear
networkdir=~/Desktop/NetworkAway
if [ ! -d $networkdir ]; then
   mkdir $networkdir
fi

check(){
if grep -q  "mmfab-server-away"  /etc/hosts; then
   echo -e "\n\n\n"
   echo "Tell Chad that mmfab-server-away is not listed in the hosts file"
   exit 1
fi

mount | grep fuse > /dev/null
if [[ $? -eq 0 ]]; then
    echo -e "\n\n\n"
    echo "You're already connected silly"
    read -p "Press any key to open the network in Finder"
    open $networkdir
    exit 0
fi
}

connect(){
echo "Yo, connectin' to da server homeslice, but fo' I do dat, what yo' username is?" 
echo ""
printf "Username: "
read user
sshfs -o defer_permissions $user@mmfab-server-away:/ $networkdir
if [[ $? -eq 0 ]]; then
    open $networkdir
    exit 0
else
    clear
    echo -e "\n\n\n"
    echo "Something went wrong."
    read -p "Press any key to close this dialog, make sure you are connected to the internet and try again. If it doesn't work the second time, call Chad"
    exit 1
fi
}
check
echo -e "\n\n\n"
connect

