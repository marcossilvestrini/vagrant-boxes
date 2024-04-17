#!/bin/bash

#  RKE2 Docs
# https://docs.rke2.io/install/quickstart
# https://docs.rke2.io/install/ha
# https://docs.rke2.io/reference/server_config
# https://computingforgeeks.com/deploy-kubernetes-on-rocky-using-rke2/?expand_article=1

<<'MULTILINE-COMMENT'
    Requirments: none
    Description: Script for install and configure rke2  as control_palne for labs.
    Author: Marcos Silvestrini
    Date: 10/10/2023
MULTILINE-COMMENT

# SET ENCODING
export LANG=C

# SET WORKDIR
WORKDIR="/home/vagrant"
cd $WORKDIR || exit

# FIX CNI CANAL
echo "FIX NETWORK INTERFACE. RKE2 GETA ETHO, BUT DNS IS SET IN ETH1. FORCE ETH1 HERE"
cp configs/rke2/rke2-canal.conf /etc/NetworkManager/conf.d
chmod 644 /etc/NetworkManager/conf.d/rke2-canal.conf
systemctl reload NetworkManager

# CREATE ETCD USER
echo "CREATE ETCD USER LOCAL..."
useradd -r -c "etcd user" -s /sbin/nologin -M etcd -U

# INSTALL RKE2 AS SERVER
echo "INSTALL RKE2 AS CONTROL PLANE"
curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE=server sh -

# INSTALL KUBECTL
echo "INSTALL KUBECTL"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# INSTALL KUBECOLOR
echo "DOWNLOAD KUBECOLOR"
wget -q https://github.com/hidetatz/kubecolor/releases/download/v0.0.25/kubecolor_0.0.25_Linux_x86_64.tar.gz
echo "EXTRACT KUBECOLOR FILES"
tar xvfz kubecolor_0.0.25_Linux_x86_64.tar.gz
echo "MOVE KUBECOLOR BINARY TO THE LOCAL USER BIN FOLDER"
mv  kubecolor /usr/local/bin
echo "SET PERMISSIONS FOR KUBECOLOR"
chmod +x /usr/local/bin/kubecolor
echo "REMOVE KUBECOLOR TRASH FILES"
rm kubecolor_0.0.25_Linux_x86_64.tar.gz LICENSE  README.md

# SET BASH SESSION
echo "SET .BASHRC FOR USER VAGRANT [CONFIGS/COMMONS/.BASHRC-OL9-KUBERNETES --> /HOME/VAGRANT/.BASHRC]"
cp -f configs/commons/.bashrc-ol9-kubernetes .bashrc
dos2unix .bashrc
echo "SET PERMISSIONS FOR USER VAGRANT IN .BASHRC"
chown vagrant:vagrant .bashrc

# SET PROPERTIES FOR USER ROOT
echo "SET .BASHRC FOR USER ROOT [/HOME/VAGRANT --> /ROOT/.BASHRC]"
cp -f .bashrc /root/

# INSTALL RANCHER CLI

# Download rancher and rancher-compose command line tools
wget -O rancher-cli.tar.gz "$(curl -s https://api.github.com/repos/rancher/cli/releases/latest | grep browser_download_url | grep 'linux-amd64' | head -n 1 | cut -d '"' -f 4)"
wget -O rancher-compose.tar.gz "$(curl -s https://api.github.com/repos/rancher/rancher-compose/releases/latest | grep browser_download_url | grep 'linux-amd64' | head -n 1 | cut -d '"' -f 4)"
## extract the binaries from the tar archive
sudo tar -xzvf rancher-cli.tar.gz -C /usr/local/bin --strip-components=2
sudo tar -xzvf rancher-compose.tar.gz -C /usr/local/bin --strip-components=2
## Remove the archive
rm rancher-cli.tar.gz rancher-compose.tar.gz -f

# INSTALL HELM
echo "INSTALL HELM..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# INSTALL ARGOCD CLI
echo "INSTALL ARGOCD CLI"
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64


