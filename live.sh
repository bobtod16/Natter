#!/bin/bash

# Function to connect to an existing network
connect_to_existing_single_network() {
    if [ ! -f "$user_login_info" ]; then
        echo "user_login_info.txt not found."
        echo "Please create network"
        create_single_network
    else
        source "$user_login_info"
        echo "Connecting......"
        sleep 3
        ssh "$username"@"$ip_address"
    fi
}


create_single_network() {
    # Define the path of the user login info file
    user_login_info="./user_login_info.txt"  # Adjust the path as needed

    echo "Ensure you have a server to ssh into"
    echo ""

    read -p "Enter username: "  username
    read -p "Enter ip address: " ip_address

    # Ask the user if SSH is set up
    read -p "Is SSH set up for the server? (yes/no): " is_ssh_setup

    case $is_ssh_setup in
        [yY]|[yY][eE][sS])
            # User indicates that SSH is set up. Ask for the key name.
            read -p "Enter the name of the .pem file (located in 'keys/' folder): " pem_file

            pem_file_path="./keys/$pem_file"

            # Check if the .pem file exists in the keys directory
            if [[ ! -e "$pem_file_path" ]]; then
                echo "The .pem file does not exist in the 'keys/' folder. Please check the filename and try again."
                return  # Exit the function
            fi
            ;;
        [nN]|[nN][oO])
            # If SSH isn't set up, continue without a .pem file.
            pem_file=""
            ;;
        *)
            echo "Invalid input. Exiting function..."
            return  # Exit the function
            ;;
    esac

    # Write the information to the user_login_info file
    echo "username=$username" > "$user_login_info"
    echo "ip_address=$ip_address" >> "$user_login_info"
    if [ -n "$pem_file" ]; then
        echo "pem_file=$pem_file" >> "$user_login_info"
    fi
}


echo "1. Connect & talk on a live server"
echo "2. Tor chat - onion share"
echo "3. Back"

read -p "SELECT ACTION: " live

#1. Sets up a live chat
if [ $live -eq 1 ]; then
    echo "1. Connect to existing network"
    echo "2. Create & connect to new network"
    echo "3. Back"

    read -p "SELECT ACTION: " network_connect

      echo "Once connected type 'who' to see who is online"
      echo "Type username@machine_ip  to initiate a chat with a user"
    # uses functions to connect to an existing network or create and connect to a new network
    case $network_connect in
        1) connect_to_existing_single_network ;;
        2) create_single_network;;
        *) echo "Invalid option" ;;
    esac



# Set up a live chat with tor
elif [ $live -eq 2 ]; then
    echo "Type or initiate tor on another terminal"

    read -p "tor at 100%: y/n: " onoff

    if [ "$onoff" == "y" ]; then

        echo "All parties must have tor installed or use the provided script to auto install required packages"
        sleep 2

        echo "Tor onion share chat room initiating…."
        sleep 3

        echo "Once connected share chat link & private key with desired parties this can be done securely with provided bash script"
        sleep 4

        echo "Once tor at 100% confirm"

        onionshare-cli --chat

    elif [ "$onoff" == "n" ]; then
        echo "If tor has failed to connect, reattempt"
        echo "For secure communication, tor is required to be at 100%"

    fi
fi