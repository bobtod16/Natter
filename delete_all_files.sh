#!/bin/bash

echo "WARNING: This will delete all files in the current directory and this cannot be undone!"
read -p "Are you sure you want to proceed? (y/n): " answer

if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    echo "Deleting all files..."
    rm -rf * && echo "Files deleted." || echo "An error occurred while deleting files."
    clear
else
    echo "Aborting."
    exit 1
fi



