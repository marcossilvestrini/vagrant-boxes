#!/bin/bash

#  RKE2 Docs
# https://docs.rke2.io/install/quickstart
# https://docs.rke2.io/install/ha
# https://docs.rke2.io/reference/server_config
# https://computingforgeeks.com/deploy-kubernetes-on-rocky-using-rke2/?expand_article=1

<<'MULTILINE-COMMENT'
    Requirments: none
    Description: Script for install and configure rke2  as agent\worker for labs.
    Author: Marcos Silvestrini
    Date: 10/10/2023
MULTILINE-COMMENT

# SET ENCODING
export LANG=C

# SET WORKDIR
WORKDIR="/home/vagrant"
cd $WORKDIR || exit

# SET DEFAULT ROUTE
ip route add default  via 192.168.0.1 dev eth1

# INSTALL RKE2 AS AGENT|WORKER
echo "INSTALL RKE2 AS WORKER"
curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sh -

