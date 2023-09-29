#!/bin/bash


# States name/use of program
echo "Command And Control"
sleep 1

# States what script can do
echo "0. Install required packages"
echo ""
echo "1. Two-way secure communication "
echo "2. Generate RSA or ECDSA Key pair"
echo "3. Encrypt/Decrypt File & images - AES/CHACHA20"
echo "4. SELF DESTRUCT "
echo "5. EXIT"
echo ""

read -p "SELECT ACTION: " choice
echo "$choice"

if [ $choice -eq 0 ]; then
    echo ""
    ./install_pack.sh

elif [ $choice -eq 1 ]; then
    ./live_dead_drop.sh


elif [ $choice -eq 2 ]; then
    ./generate_rsa_ECDSA__key_set.sh

elif [ $choice -eq 3 ]; then
     echo ""
     echo "Encrypt data at rest for better security"
     ./encrypt_decrypt.sh

elif [ $choice -eq 4 ]; then
    ./delete_all_files.sh

elif [ $choice -eq 5 ]; then


    echo "Exiting.."
    exit 1
fi

