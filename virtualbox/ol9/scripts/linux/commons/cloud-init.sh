#!/bin/bash

<<'MULTILINE-COMMENT'
    Requirments: none
    Description: Script for set environment for labs
    Author: Marcos Silvestrini
    Date: 20/02/2023
MULTILINE-COMMENT

# Set language/locale and encoding
export LANG=C

cd /home/vagrant || exit

# Get the contents of the release files
RELEASE_INFO=$(cat /etc/*release 2>/dev/null)

# Check for Debian or Ubuntu
if echo "$RELEASE_INFO" | grep -q -i "debian\|ubuntu"; then
    echo "This is a Debian or Ubuntu-based distribution."    
    # Add your Debian/Ubuntu-specific commands here
    
    ## Install packages
    apt install -y  \
        dos2unix

    elif echo "$RELEASE_INFO" | grep -q -i "oracle"; then
    echo "This is an Oracle Linux distribution."    
    # Add your Oracle Linux-specific commands here    
    
    ## Install packages
    dnf install -y \
        dos2unix

    ## Clear vagrant settings
    if [ -f "/etc/ssh/sshd_config.d/50-redhat.conf" ]; then
        rm /etc/ssh/sshd_config.d/50-redhat.conf
    fi
    if [ -f "/etc/ssh/sshd_config.d/90-redhat.conf" ]; then
        rm /etc/ssh/sshd_config.d/90-redhat.conf
    fi    
else
    echo "This distribution is not Debian, Ubuntu, or Oracle Linux."
fi

# Set custom ssh configs
cp -f configs/commons/01-sshd-custom.conf /etc/ssh/sshd_config.d
dos2unix /etc/ssh/sshd_config.d/01-sshd-custom.conf
chmod 644 /etc/ssh/sshd_config.d/01-sshd-custom.conf
systemctl restart sshd

# Set ssh
AUTHORIZED_KEYS_FILE=".ssh/authorized_keys"
PUBLIC_KEY_FILE="security/skynet-key-ecdsa.pub"
if grep -q -F -f "$PUBLIC_KEY_FILE" "$AUTHORIZED_KEYS_FILE"; then
    echo "The public key is present in the authorized_keys file."
else
    echo "The public key for ansible is not present in the authorized_keys file...Setting file..."
    cat security/skynet-key-ecdsa.pub >>.ssh/authorized_keys
fi
