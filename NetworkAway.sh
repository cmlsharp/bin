#!/bin/bash
#
# Written by: crossroads1112
# Purpose: This script was written to allow my sister's Mac to connect to her work's sftp server using sshfs. This requires FUSE for OSX to work
#
#
##############################################################################
clear
networkdir=~/Desktop/NetworkAway
if [ ! -d $networkdir ]; then #If mount location does not exist, create it
   mkdir $networkdir
fi

check(){
if grep -q  "mmfab-server-away"  /etc/hosts; then #Make sure host exists
   echo -e "\n\n\n"
   echo "Tell Chad that mmfab-server-away is not listed in the hosts file" #The real script has the IP address here instead
   exit 1
fi

if mount | grep fuse > /dev/null ; then #Check if already mounted
    echo -e "\n\n\n"
    echo "You're already connected silly"
    read -p "Press any key to open the network in Finder"
    open $networkdir #Open dir in finder
    exit 0
fi
}

connect(){
echo -e "\n\n\n"
echo "Yo, connectin' to da server homeslice, but fo' I do dat, what yo' username is?" 
echo ""
printf "Username: "
read user
sshfs -o defer_permissions $user@mmfab-server-away:/ $networkdir
if [[ $? -eq 0 ]]; then #Make sure previous command worked
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
connect
