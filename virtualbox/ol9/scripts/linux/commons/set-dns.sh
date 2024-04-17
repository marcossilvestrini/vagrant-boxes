#!/bin/bash

<<'MULTILINE-COMMENT'
    Requirments: none
    Description: Script for set DNS server
    Author: Marcos Silvestrini
    Date: 10/08/2023
MULTILINE-COMMENT

# Set language/locale and encoding
export LANG=C

cd /home/vagrant || exit

## Set resolv.conf file
rm /etc/resolv.conf
cp configs/commons/resolv.conf.manually-configured /etc
dos2unix  /etc/resolv.conf.manually-configured
ln -s /etc/resolv.conf.manually-configured /etc/resolv.conf