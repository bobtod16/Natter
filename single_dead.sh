#!/bin/bash

#This script is a digital dead drop that allows two users to communicate securely using RSA encryption
#The script uses a server to exchange messages and files between the two users
#Ensure that the server is set up with SSH,

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
        if [ -n "$pem_file" ]; then
            ssh -i "./keys/$pem_file" "$username@$ip_address"
        else
            ssh "$username@$ip_address"
        fi
    fi
}


create_single_network() {
    echo "Ensure you have a server to ssh into"
    echo ""
    read -p "Enter username: "  username
    read -p "Enter ip address: " ip_address

    # Ask the user if SSH is set up
    read -p "Is SSH set up for the server? (yes/no): " is_ssh_setup

    case $is_ssh_setup in
        [yY]|[yY][eE][sS])
            read -p "Enter the name of the .pem file (located in 'keys/' folder): " pem_file
            pem_file_path="./keys/$pem_file"
            if [[ ! -e "$pem_file_path" ]]; then
                echo "The .pem file does not exist in the 'keys/' folder. Please check the filename and try again."
                return
            fi
            ;;
        [nN]|[nN][oO])
            pem_file=""
            ;;
        *)
            echo "Invalid input. Exiting function..."
            return
            ;;
    esac

    echo "username=$username" > "$user_login_info"
    echo "ip_address=$ip_address" >> "$user_login_info"
    if [ -n "$pem_file" ]; then
        echo "pem_file=$pem_file" >> "$user_login_info"
    fi
}



send_file() {
    # Get the file name from the user
    read -p "Enter the path to the file you want to send: " file_path

    # Check if the file exists
    if [[ ! -f $file_path ]]; then
        echo "Error: File not found."
        return 1
    fi

    # Get the remote server details (assuming you've previously set these details)
    # Otherwise, you can prompt the user for these details every time
    source "$user_login_info" # this assumes the file contains username and ip_address as in your previous function

    # Send the file using scp
    scp "$file_path" "$username@$ip_address:~/"

    if [[ $? -eq 0 ]]; then
        echo "File sent successfully!"
    else
        echo "Error sending the file."
    fi
}


#Useful once a message as it will keep looping until we get a reply from the other user
function check_user_message_receipt() {

     while true; do
        source "$user_login_info"
        if ssh "${username}@${ip_address}" "test  -e message-for-user-${user}_msg.txt.enc"; then
            break

        elif ssh "${username}@${ip_address}" "test ! -e message-for-user-${other_user}_msg.txt.enc"; then
            echo "Message received by other user..... Waiting for response"
            sleep 30

        fi
    done

}



function send_message() {
    read -p "Enter message: " user_msg
    echo "Sending message to user-${other_user}..."
    other_user=$((3 - $user))
    echo "$user_msg" > "message-for-user-${other_user}_msg.txt"
    openssl pkeyutl -encrypt -inkey "user-${other_user}_keys/public_key.pem" -pubin -in "message-for-user-${other_user}_msg.txt" -out "message-for-user-${other_user}_msg.txt.enc"
    source "$user_login_info"
    scp "message-for-user-${other_user}_msg.txt.enc" "${username}@${ip_address}:"
    echo "Message sent"
    rm "message-for-user-${other_user}_msg.txt" "message-for-user-${other_user}_msg.txt.enc"


}

function check_message() {
    echo "Message from user-${other_user}"
    echo ""
    source "$user_login_info"
    scp "${username}@${ip_address}:message-for-user-${user}_msg.txt.enc" .
    openssl pkeyutl -decrypt -inkey "keys/private_key.pem" -in "message-for-user-${user}_msg.txt.enc" -out "message-for-user-${user}_msg.txt"
    cat "message-for-user-${user}_msg.txt"
    ssh "${username}@${ip_address}" "rm message-for-user-${user}_msg.txt.enc"
    echo "Deleted received message from server"
    rm "message-for-user-${user}_msg.txt" "message-for-user-${user}_msg.txt.enc"


}

while true; do
    echo "Single Digital Dead Drop"
    echo ""
    echo "1. RSA - Use a single RSA key pair"
    echo "2. Exit"
    echo ""
    read -p "SELECT Mode: " mode

    if [ "$mode" -eq 2 ]; then
        echo "Exiting the script."
        break
    elif [ "$mode" -ne 1 ]; then
        echo "Invalid choice. Please try again."
        continue
    fi

    echo "User number must not match other party"
    echo ""
    echo "1. user-1"
    echo "2. user-2"
    echo ""
    read -p "Enter user: " user

    if [ "$user" -ne 1 ] && [ "$user" -ne 2 ]; then
        echo "Invalid user choice."
        continue
    fi

    if [ "$mode" -eq 1 ]; then
        echo "Public keys must first be exchanged with other party to ensure secure communication"
        echo ""
        echo "1. Send"
        echo "2. Receive"
        echo "3. Send & receive - Fast dead drop"
        echo "4. Exchange public keys"
        echo "5. Back"

        read -p "SELECT ACTION: " dead_drop

        other_user=$((3 - user))

        if [ "$dead_drop" -eq 1 ]; then
            echo ""
            echo "1. Send message"
            echo "2. Send file"
            echo "3. back"
            read -p "SELECT ACTION: " msg_or_file

            if [ "$msg_or_file" -eq 1 ]; then
                send_message
            elif [ "$msg_or_file" -eq 2 ]; then
                send_file
            else
                continue
            fi
        elif [ "$dead_drop" -eq 2 ]; then
            check_message
        elif [ "$dead_drop" -eq 3 ]; then

            while true; do
                    source "$user_login_info"
                    if ssh "${username}@${ip_address}" "test -e message-for-user-${user}_msg.txt.enc"; then
                          check_message

                    elif ssh "${username}@${ip_address}" "test ! -e message-for-user-${other_user}_msg.txt.enc"; then
                          send_message
                          check_user_message_receipt

                    fi

                done

        elif [ "$dead_drop" -eq 4 ]; then
            echo "Exchange public keys"
                echo ""
                echo "Other parties keys will be stored in {user-${other_user}_keys}"
                echo ""
                echo "1. Use existing keys"
                echo "2. Generate new key pair"
                echo "3. Back"
                read -p "ENTER SELECTION: " key_gen

                if [ "$key_gen" -eq 1 ]; then
                    if [ ! -d "keys" ]; then
                        echo "No existing keys, Generate a RSA key pair"
                        ./generate_rsa_key_set.sh
                        continue

                elif [ "$key_gen" -eq 2 ]; then
                    ./generate_rsa_key_set.sh

                elif [ "$key_gen" -eq 3 ]; then
                    continue
                fi
            fi

            my_keys="keys/public_key.pem"

             # Check if the public key file exists
            if [ ! -f "${my_keys}" ]; then
                echo "Public key file not found. Please generate keys first."
                continue
            fi

            echo "Sending your public key to the contact..."
            source "$user_login_info"

            scp "${my_keys}" "${username}@${ip_address}:user-${user}_public_key.pem"
            echo "Successfully sent your public key."

            echo "Checking for other user's public key..."
            sleep 10
            other_user=$((3 - user))

            while true; do

                scp "$username"@"$ip_address":user-${other_user}_public_key.pem  .

                if [ -f "user-${other_user}_public_key.pem" ]; then
                    if [ ! -d "user-${other_user}_keys" ]; then
                        mkdir "user-${other_user}_keys"
                    fi

                    mv "user-${other_user}_public_key.pem" "public_key.pem"
                    mv "public_key.pem" "user-${other_user}_keys"
                    echo "Successfully received other user's public key."

                    # Deletes other user's key once grabbed
                    ssh "${username}@${ip_address}" "rm user-${other_user}_public_key.pem"
                    echo "Deleted other user's public key."

                    break
                else
                    echo "Other user's public key not found. Retrying in 5 seconds."
                    sleep 5
                fi
            done

        elif [ "$dead_drop" -eq 5 ]; then
            echo "Going back."
            continue
        else
            echo "Invalid choice. Please try again."
        fi
    elif [ "$mode" -eq 2 ]; then
        echo "Exiting the script."
        break
    else
        echo "Invalid choice. Please try again."
    fi
done
