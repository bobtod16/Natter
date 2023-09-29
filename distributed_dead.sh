chosen_ip=""
chosen_key=""

username="azureuser"
ip_address="$chosen_ip"

function send_file() {
    read -p "Enter the path to the file you want to send: " file_path

    if [[ ! -f $file_path ]]; then
        echo "Error: File not found."
        return 1
    fi

    if scp -i keys/"$chosen_key" "$file_path" "${username}@${ip_address}:~/"; then
        echo "File sent successfully!"
    else
        echo "Error sending the file."
    fi
}

function check_user_message_receipt() {
    while true; do
        if ssh -i keys/"$chosen_key" "${username}@${ip_address}" "test -e message-for-user-${user}_msg.txt.enc"; then
            break
        elif ssh -i keys/"$chosen_key" "${username}@${ip_address}" "test -e message-for-user-${other_user}_msg.txt.enc"; then
            echo "Message received by other user..... Waiting for response"
            sleep 30
        else
            echo "Error checking message receipt. Retrying..."
            sleep 10
        fi
    done
}

function send_message() {
    read -p "Enter message: " user_msg
    other_user=$((3 - $user))
    echo "$user_msg" > "message-for-user-${other_user}_msg.txt"
    openssl pkeyutl -encrypt -inkey "user-${other_user}_keys/public_key.pem" -pubin -in "message-for-user-${other_user}_msg.txt" -out "message-for-user-${other_user}_msg.txt.enc"

    scp -i keys/"$chosen_key" "message-for-user-${other_user}_msg.txt.enc" "${username}@${ip_address}:"
    echo "Message sent"
    rm "message-for-user-${other_user}_msg.txt" "message-for-user-${other_user}_msg.txt.enc"
}

function check_message() {
    ip_address="$chosen_ip"

    scp -i keys/"$chosen_key" "${username}@${ip_address}:message-for-user-${user}_msg.txt.enc" .
    openssl pkeyutl -decrypt -inkey "keys/private_key.pem" -in "message-for-user-${user}_msg.txt.enc" -out "message-for-user-${user}_msg.txt"
    cat "message-for-user-${user}_msg.txt"
    ssh -i keys/"$chosen_key" "${username}@${ip_address}" "rm message-for-user-${user}_msg.txt.enc"
    echo "Deleted received message from server"
    rm "message-for-user-${user}_msg.txt" "message-for-user-${user}_msg.txt.enc"
}


function ssh_random_azure() {
    random_line=$(shuf -n 1 login_info.csv)
    chosen_ip=$(echo $random_line | awk -F, '{print $1}')
    chosen_key=$(echo $random_line | awk -F, '{print $2}')

    # Update ip_address here
    ip_address="$chosen_ip"

    echo "Chosen IP: $chosen_ip"
    echo "Chosen Key: $chosen_key"
}



function ssh_select_azure() {
    echo "Select an IP and key pair by number:"
    select option in $(cat login_info.csv); do
        if [[ -n $option ]]; then
            chosen_ip=$(echo $option | awk -F, '{print $1}')
            chosen_key=$(echo $option | awk -F, '{print $2}')

            # Update ip_address here
            ip_address="$chosen_ip"

            echo "Chosen IP: $chosen_ip"
            echo "Chosen Key: $chosen_key"
            break
        else
            echo "Invalid option. Please select a valid number."
        fi
    done
}


function ssh_azure() {
    echo "Ensure the other party has the same selected IP and key."
    echo ""
    echo "1. SSH to a random Azure instance"
    echo "2. Select an Azure instance to SSH"
    echo "3. Return to the previous menu"
    read -p "Choose an option: " ssh_option

    case $ssh_option in
        1) ssh_random_azure ;;
        2) ssh_select_azure ;;
        3) return ;;
        *) echo "Invalid option" ;;
    esac
}

while true; do
    echo "Distributed Digital Dead Drop"
    echo ""
    echo "1. Initiate Distributed Digital Dead Drop"
    echo "2. Exit"
    echo ""
    read -p "SELECT Mode: " mode

    case $mode in
        1)
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
            other_user=$((3 - user))

            ssh_azure


            echo "Public keys must first be exchanged with other party to ensure secure communication"
            echo ""
            echo "1. Send"
            echo "2. Receive"
            echo "3. Send & receive - Fast dead drop"
            echo "4. Exchange public keys"
            echo "5. Back"
            read -p "SELECT ACTION: " dead_drop

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
              elif [ "$msg_or_file" -eq 3 ]; then
                continue
              else
                echo "Invalid choice"
                continue
              fi
            elif [ "$dead_drop" -eq 2 ]; then
              check_message

            elif [ "$dead_drop" -eq 3 ]; then

                  while true; do

#                    username="azureuser"
#                    ip_address="$chosen_ip"

                    if ssh "${username}@${ip_address}" "test -e message-for-user-${user}_msg.txt.enc"; then
                          check_message

                    elif ssh "${username}@${ip_address}" "test ! -e message-for-user-${other_user}_msg.txt.enc"; then
                          send_message
                          check_user_message_receipt

                    fi

                done

            elif [ "$dead_drop" -eq 4 ]; then

#              username="azureuser"
#              ip_address="$chosen_ip"

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
                      echo "No existing keys, Generate RSA key pair"
                      ./generate_rsa_key_set.sh
                  fi
              elif [ "$key_gen" -eq 2 ]; then
                  ./generate_rsa_key_set.sh
              elif [ "$key_gen" -eq 3 ]; then
                  continue
              else
                  echo "Invalid choice for key generation option."
              fi


            my_keys="keys/public_key.pem"

             # Check if the public key file exists
            if [ ! -f "${my_keys}" ]; then
                echo "Public key file not found. Please generate keys first."
                continue
            fi

            echo "Sending your public key to the contact..."


            scp "${my_keys}" "${username}@${chosen_ip}:user-${user}_public_key.pem"
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
                    echo "Other user's public key not found. Retrying in 10 seconds."
                    sleep 10
                fi
            done

        elif [ "$dead_drop" -eq 5 ]; then
            echo "Going back."
            continue
        else
            echo "Invalid choice. Please try again."
        fi

        ;;
        2)

            # ... [Rest of your code that processes the "dead_drop" choice] ...

            ;;
        3)
            echo "Exiting the script."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
done