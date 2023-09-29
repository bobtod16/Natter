#!/bin/bash

# Paths to the necessary files
distributed_login_info="./login_info.csv"
inactive_networks="./inactive_networks.csv"

# Ensure the inactive_networks.csv file exists. If not, create it with headers
if [[ ! -e "$inactive_networks" ]]; then
    echo "ip_address,pem_file" > "$inactive_networks"
fi

# Check if the login_info.csv file exists. If not, inform the user and exit.
if [[ ! -e "$distributed_login_info" ]]; then
    echo "No saved network connections. The login_info.csv file does not exist."
    exit 1
fi

# Read each line from the distributed_login_info file
while IFS=',' read -r ip_address pem_file; do
    # Ignore the header line
    if [[ "$ip_address" == "ip_address" ]]; then
        continue
    fi

    # SSH into the server to check if it's active
    if ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -i "./keys/$pem_file" azureuser@"$ip_address" 'echo "Connection is live. Logging out now." && exit' < /dev/null 2>/dev/null; then
        echo "$ip_address is active."
    else
        echo "$ip_address is inactive."
        # Add the IP and .pem file to inactive_networks.csv
        echo "$ip_address,$pem_file" >> "$inactive_networks"

        # Remove the entry from distributed_login_info.csv
        sed -i "/$ip_address,$pem_file/d" "$distributed_login_info"
    fi

done < "$distributed_login_info"
