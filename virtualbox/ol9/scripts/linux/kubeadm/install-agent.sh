#!/bin/bash

<<'MULTILINE-COMMENT'
    Requirments: none
    Description: Script for install and configure k8s as worker for labs.
    Author: Marcos Silvestrini
    Date: 12/07/2023
MULTILINE-COMMENT

# Set language/locale and encoding
export LANG=C

# Set workdir
WORKDIR="/home/vagrant"
cd $WORKDIR || exit

# Variables
DISTRO=$(cat /etc/*release | grep -ws NAME=)
NODE_MASTER="control-plane01"
NODE_NAME=$(hostname)
IP_NODE=$(hostname -i)
TOKEN=""
TOKEN_CA=""

# Check if distribution is RPM-->Oracle Linux Server
if [[ "$DISTRO" == *"Oracle"* ]]; then
    echo "Distribution is Oracle Linux Server...Congratulations!!!"
else
    echo "This script is available only Oracle Linux Server distributions!!!";exit 1;
fi

# Set default route for RKE2
ip route add default  via 192.168.0.1 dev eth1

# Disables Swap
sudo swapoff -a

# join node in control plane
# sudo kubeadm join "$NODE_MASTER:6443" --token "$TOKEN" \
#     --discovery-token-ca-cert-hash "$TOKEN_CA"

# install Weave Net in control plane
# sshpass -p 'vagrant' ssh -o StrictHostKeyChecking=no root@$NODE_MASTER -l root \
#     kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
