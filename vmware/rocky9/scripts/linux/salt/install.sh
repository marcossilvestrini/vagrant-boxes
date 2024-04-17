#!/bin/bash

<<'MULTILINE-COMMENT'
    Requirments: none
    Description: Script for install and configure Saltstack
    Author: Marcos Silvestrini
    Date: 18/09/2023
MULTILINE-COMMENT

# functions
function init() {
    # Set language/locale and encoding
    export LANG=C

    # Set workdir
    WORKDIR="/home/vagrant"
    cd $WORKDIR || exit

    # Variables
    DISTRO=$(cat /etc/*release | grep -ws NAME=)    

    # Check if distribution is RPM-->Oracle Linux Server
    if [[ "$DISTRO" == *"Oracle"* ]]; then
        echo "CHECK IF DISTRIBUTION IS ORACLE..."
        echo "CONGRATULATIONS, YOUR DISTRO SO GOOD!"
    else
        echo "THIS SCRIPT IS AVAILABLE ONLY ORACLE LINUX SERVER DISTRIBUTIONS!!!"
        exit 1
    fi
}

function install-salt() {
    # Run the following commands to install the Salt Project repository and key
    rpm --import https://repo.saltproject.io/salt/py3/fedora/38/x86_64/SALT-PROJECT-GPG-PUBKEY-2023.pub
    curl -fsSL https://repo.saltproject.io/salt/py3/fedora/38/x86_64/latest.repo | tee /etc/yum.repos.d/salt.repo

    # clear cache
    dnf clean expire-cache

    # Install the salt-minion, salt-master, or other Salt components
    echo "CONFIGURE SALT MASTER IN $(hostname -f)"

    # Create salt directories
    mkdir -p /srv/{salt,pillar}

    # Instal saltsatck
    dnf install -y salt-master
    dnf install -y salt-ssh
    dnf install -y salt-syndic
    dnf install -y salt-cloud
    dnf install -y salt-api   
    
}

# Main
init
install-salt
