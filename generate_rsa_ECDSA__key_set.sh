#!/bin/bash

KEY_DIR="keys"
if [ ! -d "$KEY_DIR" ]; then
  mkdir "$KEY_DIR"
fi

check_and_create() {
  KEY_PATH=$1
  if [[ -f $KEY_PATH ]]; then
    read -p "The key $KEY_PATH already exists. Overwrite? (yes/no): " overwrite
    if [[ $overwrite == "yes" ]]; then
      return 0
    else
      echo "Key generation aborted."
      exit
    fi
  fi
  return 0
}

while true; do
    echo "Select key pair type:"
    echo "1. RSA"
    echo "2. ECDSA"
    echo "3. EXIT"
    read -p "Enter your choice (1-3): " choice

    case $choice in
        1)
            echo "You selected RSA"
            echo "Select bit size:"
            echo "1. 2048 bit"
            echo "2. 4096 bit - recommend"
            read -p "Enter bit count (1-2): " bits

            if [[ $bits == 1 ]]; then
                check_and_create "${KEY_DIR}/private_key.pem"
                openssl genrsa -out "${KEY_DIR}/private_key.pem" 2048
                openssl rsa -in "${KEY_DIR}/private_key.pem" -pubout -out "${KEY_DIR}/public_key.pem"
                break
            elif [[ $bits == 2 ]]; then
                check_and_create "${KEY_DIR}/private_key.pem"
                openssl genrsa -out "${KEY_DIR}/private_key.pem" 4096
                openssl rsa -in "${KEY_DIR}/private_key.pem" -pubout -out "${KEY_DIR}/public_key.pem"
                break
            else
                echo "Invalid choice. Try again."
            fi
            ;;
        2)
            echo "You selected ECDSA"
            echo "Select curve:"
            echo "1. secp256k1"
            echo "2. secp384r1"
            echo "3. secp521r1"
            read -p "Enter curve choice (1-3): " curve

            case $curve in
                1)
                    check_and_create "${KEY_DIR}/ecdsa_private_key.pem"
                    openssl ecparam -name secp256k1 -genkey -noout -out "${KEY_DIR}/ecdsa_private_key.pem"
                    ;;
                2)
                    check_and_create "${KEY_DIR}/ecdsa_private_key.pem"
                    openssl ecparam -name secp384r1 -genkey -noout -out "${KEY_DIR}/ecdsa_private_key.pem"
                    ;;
                3)
                    check_and_create "${KEY_DIR}/ecdsa_private_key.pem"
                    openssl ecparam -name secp521r1 -genkey -noout -out "${KEY_DIR}/ecdsa_private_key.pem"
                    ;;
                *)
                    echo "Invalid choice. Try again."
                    continue
                    ;;
            esac
            openssl ec -in "${KEY_DIR}/ecdsa_private_key.pem" -pubout -out "${KEY_DIR}/ecdsa_public_key.pem"
            break
            ;;
        3)
            exit
            ;;
        *)
            echo "Invalid choice. Try again."
            ;;
    esac
done
