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

# Set password account
#usermod --password $(echo vagrant | openssl passwd -1 -stdin) vagrant
#usermod --password $(echo vagrant | openssl passwd -1 -stdin) root

# # Enable Epel repo
dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y

# Install packages
dnf update -y
dnf install -y \
bash-completion \
vim \
curl \
git \
dos2unix \
sshpass \
htop \
lsof \
tree \
net-tools \
bind-utils \
telnet \
traceroute \
sysstat \
NetworkManager-initscripts-updown \
python3-pip \
zip \
lvm2 \
cryptsetup  \
iscsi-initiator-utils \
jq \
nfs-utils \
rsync \
httpd-tools \
expect \
salt-minion

# Set profile in /etc/profile
cp -f configs/commons/profile-ol9 /etc/profile
dos2unix /etc/profile

# Set vim profile
cp -f configs/commons/.vimrc .
dos2unix .vimrc
chown vagrant:vagrant .vimrc

# Set bash session
cp -f configs/commons/.bashrc-ol9 .bashrc
dos2unix .bashrc
chown vagrant:vagrant .bashrc

# Set properties for user root
cp -f .bashrc .vimrc /root/

# Enabling IP forwarding on Linux
cp configs/commons/sysctl.conf /etc
dos2unix /etc/sysctl.conf
systemctl daemon-reload

# SSH,FIREWALLD AND SELINUX
if [ -f "/etc/ssh/sshd_config.d/50-redhat.conf" ]; then
    rm /etc/ssh/sshd_config.d/50-redhat.conf
fi
cp -f configs/commons/01-sshd-custom.conf /etc/ssh/sshd_config.d
dos2unix /etc/ssh/sshd_config.d/01-sshd-custom.conf
chmod 644 /etc/ssh/sshd_config.d/01-sshd-custom.conf
systemctl restart sshd
echo vagrant | $(su -c "ssh-keygen -q -t ecdsa -b 521 -N '' -f .ssh/id_ecdsa <<<y >/dev/null 2>&1" -s /bin/bash vagrant)
systemctl restart sshd
systemctl stop firewalld
systemctl disable firewalld
setenforce Permissive
systemctl start nftables
systemctl enable nftables

## set your public key here
cat security/id_ecdsa.pub >>.ssh/authorized_keys

# Install X11 Server
dnf config-manager --set-enabled ol9_codeready_builder
dnf update -y
dnf install -y xorg-x11-server-Xorg.x86_64 xorg-x11-xauth.x86_64 \
xorg-x11-server-utils.x86_64 xorg-x11-utils.x86_64

# Enable sadc collected system activity
cp -f configs/commons/sysstat /etc/default/
dos2unix /etc/default/sysstat
systemctl start sysstat sysstat-collect.timer sysstat-summary.timer
systemctl enable sysstat sysstat-collect.timer sysstat-summary.timer

# Set Default DNS Server

## Copy host file
cp -f configs/commons/hosts /etc
dos2unix /etc/hosts

## Set Networkmanager
cp -f configs/commons/01-NetworkManager-custom.conf /etc/NetworkManager/conf.d/
dos2unix /etc/NetworkManager/conf.d/01-NetworkManager-custom.conf
systemctl reload NetworkManager

# Set iscsid
systemctl start iscsid.service
systemctl enable iscsid.service

# Clean updates
#dnf clean all
