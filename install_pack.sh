#!/bin/bash

# Installs required packages for the script to run

read -p "Install required packages (y/n) -requires root " installs

if [ "$installs" == "y" ]; then

    sudo apt-get update && sudo apt-get upgrade
    sudo apt-get install talk talkd
    sudo apt-get install openssl
    sudo apt-get install sshpass

    # For onion share
    sudo apt-get install tor	
    sudo apt install tor onionshare
    sudo apt-get install torsocks
    pip3 install --user onionshare-cli
    sudo apt update

    #other
    sudo apt install dos2unix
    dos2unix distributed.sh

    # Clears screen of installs after 5 seconds
    sleep 5
    clear

elif [ "$installs" == "n" ]; then
    echo "Skipping package installation."
else
    echo "Invalid choice"
fi



