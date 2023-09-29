#!/bin/bash

while true; do
    echo "En/(De)crypt text and image files"
    echo ""
    echo "1. Encrypt"
    echo "2. Decrypt"
    echo "3. EXIT"
    echo ""
    read -p "SELECT ACTION: " choice

    if [[ $choice -eq 3 ]]; then
        exit 0
    fi

    declare -a selected_files

    if [[ $choice -eq 1 ]]; then
        files=($(find . -type f \( -name "*.img" -o -name "*.txt" \)))
    elif [[ $choice -eq 2 ]]; then
        files=($(find . -type f -name "*.enc"))
    fi

    if [[ ${#files[@]} -eq 0 ]]; then
        echo "No relevant files found."
        continue
    fi

    echo "Please select files from the list below by entering numbers separated by spaces or type 'back' to return to the main menu:"
    select file in "All" "${files[@]}" "Done"; do
        if [[ "$REPLY" == "back" ]]; then
            continue 2
        elif [[ "$file" == "All" ]]; then
            selected_files=("${files[@]}")
            echo "All files have been selected for processing."
            break
        elif [[ "$file" == "Done" ]]; then
            break
        elif [[ -n "$file" ]]; then
            selected_files+=("$file")
            echo "Added $file to processing list"
        else
            echo "Invalid selection. Please try again."
            continue
        fi
    done

    echo "Select encryption standard"
    echo "1. AES-256"
    echo "2. ChaCha20"
    echo "3. Back to main menu"
    echo "4. EXIT"
    read -p "SELECT ENCRYPTION: " encryption_standard

    case $encryption_standard in
        3) continue ;;
        4) exit 0 ;;
    esac

    read -sp "Enter password: " enc_password
    echo ""
    echo "******"

    for file in "${selected_files[@]}"; do
        if [[ $choice -eq 1 ]]; then
            if [[ $encryption_standard -eq 1 ]]; then
                openssl enc -aes-256-cbc -salt -in "$file" -out "${file}.enc" -pass pass:"$enc_password" -pbkdf2 && rm "$file" || echo "Encryption failed for $file!"
            elif [[ $encryption_standard -eq 2 ]]; then
                openssl enc -chacha20 -salt -in "$file" -out "${file}.enc" -pass pass:"$enc_password" -pbkdf2 && rm "$file" || echo "Encryption failed for $file!"
            fi
        elif [[ $choice -eq 2 ]]; then
            output_file="${file%.enc}"
            if [[ $encryption_standard -eq 1 ]]; then
                openssl enc -aes-256-cbc -d -salt -in "$file" -out "$output_file" -pass pass:"$enc_password" -pbkdf2 && rm "$file" || echo "Decryption failed for $file!"
            elif [[ $encryption_standard -eq 2 ]]; then
                openssl enc -chacha20 -d -salt -in "$file" -out "$output_file" -pass pass:"$enc_password" -pbkdf2 && rm "$file" || echo "Decryption failed for $file!"
            fi
        fi
    done
    echo "Operation completed for selected files!"
    sleep 5
    clear
done
