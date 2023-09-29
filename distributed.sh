#!/bin/bash

create_distributed_network() {
    # Define the path of the distributed login info file
    distributed_login_info="./login_info.csv"  # Adjust the path as needed

    # Check if the file already exists
    if [[ -e "$distributed_login_info" ]]; then
        read -p "The file 'login_info.csv' already exists. Do you want to override it add more entries? (override/add): " file_decision

        case $file_decision in
            [oO][vV][eE][rR][rR][iI][dD][eE])
                echo "ip_address,pem_file" > "$distributed_login_info" # override the file with new headers
                ;;
            [aA][dD][dD])
                # Continue with the existing file
                ;;
            *)
                echo "Invalid input. Exiting..."
                exit 1
                ;;
        esac
    else
        # If the file doesn't exist, create it with headers
        echo "ip_address,pem_file" > "$distributed_login_info"
    fi

    while true; do
        echo "Ensure you have servers to ssh into"
        echo ""

        read -p "Enter ip address: " ip_address
        read -p "Enter the name of the .pem file (located in 'keys/' folder): " pem_file

        pem_file_path="./keys/$pem_file"

        # Check if the .pem file exists
        if [[ ! -e "$pem_file_path" ]]; then
            echo "The .pem file does not exist in the 'keys/' folder. Please check the filename and try again."
            continue
        fi

        # Check if the combination of IP and pem_file already exists in the file
        if grep -q "$ip_address,$pem_file" "$distributed_login_info"; then
            echo "This IP and .pem file combination already exists."
        else
            echo "$ip_address,$pem_file" >> "$distributed_login_info"
        fi

        # Ask the user if they want to continue or exit
        read -p "Would you like to enter another server? (yes/no): " answer

        case $answer in
            [yY]|[yY][eE][sS])
                continue
                ;;
            [nN]|[nN][oO])
                break
                ;;
            *)
                echo "Invalid input. Please answer yes or no."
                ;;
        esac


    done
}

create_distributed_network
