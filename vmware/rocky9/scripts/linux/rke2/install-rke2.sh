#!/bin/bash

#  RKE2 Docs
# https://docs.rke2.io/install/quickstart
# https://docs.rke2.io/install/ha
# https://docs.rke2.io/reference/server_config
# https://computingforgeeks.com/deploy-kubernetes-on-rocky-using-rke2/?expand_article=1

<<'MULTILINE-COMMENT'
    Requirments: none
    Description: Script for install and configure rke2  as node\control_palne for labs.
    Author: Marcos Silvestrini
    Date: 21/07/2023
MULTILINE-COMMENT

# Function for init procedures
function init(){
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
    
    # Check if distribution is RPM-->Oracle Linux Server
    if [[ "$DISTRO" == *"Oracle"* ]]; then
        echo "CHECK IF DISTRIBUTION IS ORACLE..."
        echo "CONGRATULATIONS, YOUR DISTRO SO GOOD!"
    else
        echo "THIS SCRIPT IS AVAILABLE ONLY ORACLE LINUX SERVER DISTRIBUTIONS!!!";exit 1;
    fi
    
    # Get token
    if [[ "$NODE_NAME" == *"worker"* ]]; then
        echo "GET CLUSTER TOKEN..."
        TOKEN_NODE=$(cat configs/rke2/token-first-node)
    fi
}

function install-rke2(){
    # install server node    
    if [[ "$NODE_NAME" == *"plane"* ]];then
        echo "INSTALL RKE2 AS CONTROL PLANE"
        curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE=server sh -
    else
        # install server node
        echo "INSTALL RKE2 AS WORKER"
        curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sh -
    fi
}

function set-network(){
    # Set default route for RKE2
    ip route add default  via 192.168.0.1 dev eth1
    if [[ "$NODE_NAME" == *"plane"* ]];then
        echo "FIX NETWORK INTERFACE. RKE2 GETA ETHO, BUT DNS IS SET IN ETH1. FORCE ETH1 HERE"
        cp configs/rke2/rke2-canal.conf /etc/NetworkManager/conf.d
        chmod 644 /etc/NetworkManager/conf.d/rke2-canal.conf
        systemctl reload NetworkManager
    fi
}

function set-rke2(){
    if [[ "$NODE_NAME" == *"plane"* ]];then
        
        # Create etcd user
        echo "CREATE ETCD USER LOCAL..."
        useradd -r -c "etcd user" -s /sbin/nologin -M etcd -U
        
        # Fix error create etcd pod
        if [ -f "/var/lib/rancher/rke2/agent/pod-manifests/etcd.yaml" ]; then
            rm  /var/lib/rancher/rke2/agent/pod-manifests/etcd.yaml
        fi
        
        # set first node
        if [[ "$NODE_MASTER" == *"$NODE_NAME"* ]]; then
            echo "CONFIGURE FIRST NODE $(hostname -f)"
            
            # Set first node
            cp configs/rke2/config-first-node.yaml /etc/rancher/rke2/config.yaml
            chmod 600 /etc/rancher/rke2/config.yaml
            sed -i "s/ipNode/$IP_NODE/g" /etc/rancher/rke2/config.yaml
            
            # enable service
            systemctl enable rke2-server.service
            
            # start the service
            echo "RESTART RKE2 SERVICE AFTER APPLY [/etc/rancher/rke2/config.yaml]"
            systemctl restart rke2-server.service
            
            # save first node token
            TOKEN_NODE=$(cat /var/lib/rancher/rke2/server/node-token)
            echo "$TOKEN_NODE" > configs/rke2/token-first-node
            
        else
            echo "ADD NODE $(hostname -f) IN CLUSTER"
            
            # Add nodes to cluster
            cp configs/rke2/config-nodes.yaml /etc/rancher/rke2/config.yaml
            chmod 600 /etc/rancher/rke2/config.yaml
            
            # Get server node token
            TOKEN_NODE=$(cat configs/rke2/token-first-node)
            sed -i "s/tokenNode/$TOKEN_NODE/g" /etc/rancher/rke2/config.yaml
            sed -i "s/ipNode/$IP_NODE/g" /etc/rancher/rke2/config.yaml
            
            # enable service
            systemctl enable rke2-server.service
            
            # start the service
            echo "RESTART RKE2 SERVICE AFTER APPLY [/etc/rancher/rke2/config.yaml]"
            systemctl restart rke2-server.service
            
        fi
        
    else
        echo "CONFIGURE NODE WORKER $(hostname -f)"
        
        # set agent
        mkdir -p /etc/rancher/rke2
        cp configs/rke2/config-agent.yaml /etc/rancher/rke2/config.yaml
        chmod 600 /etc/rancher/rke2/config.yaml
        sed -i "s/tokenNode/$TOKEN_NODE/g" /etc/rancher/rke2/config.yaml
        
        # enable service
        systemctl enable rke2-agent.service
        
        # start the service
        systemctl restart rke2-agent.service
    fi
}

function set-tools(){
    # Set kubeconfig - pre req for ArgoCD instalation
    if [[ "$NODE_MASTER" == "$NODE_NAME" ]]; then
        mkdir -p {/root/.kube/config,/home/vagrant/.kube/config}
        cp /etc/rancher/rke2/rke2.yaml /root/.kube/config/kubeconfig
        cp /etc/rancher/rke2/rke2.yaml /home/vagrant/.kube/config/kubeconfig
        sed -i "s/https:\/\/192.168.0.140:6443/https:\/\/rancher.skynet.com.br:6443/g" /root/.kube/config/kubeconfig
        sed -i "s/https:\/\/192.168.0.140:6443/https:\/\/rancher.skynet.com.br:6443/g" /home/vagrant/.kube/config/kubeconfig
    fi
    if [[ "$NODE_NAME" == *"plane"* ]];then
        # Install Helm
        echo "INSTALL HELM..."
        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
        
        # Copy kubectl binary to the local user bin folder
        echo "COPY KUBECTL BINARY TO THE LOCAL USER BIN FOLDER"
        cp /var/lib/rancher/rke2/bin/kubectl /usr/local/bin
    else
        echo "INSTALL KUBECTL..."
        curl -LO https://storage.googleapis.com/kubernetes-release/release/"$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)"/bin/linux/amd64/kubectl
        chmod +x ./kubectl
        mv ./kubectl /usr/local/bin/kubectl
    fi
    
    # Install kubecolor
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
    
    # Set bash session
    echo "SET .BASHRC FOR USER VAGRANT [CONFIGS/COMMONS/.BASHRC-OL9-KUBERNETES --> /HOME/VAGRANT/.BASHRC]"
    cp -f configs/commons/.bashrc-ol9-kubernetes .bashrc
    dos2unix .bashrc
    
    echo "SET PERMISSIONS FOR USER VAGRANT IN .BASHRC"
    chown vagrant:vagrant .bashrc
    
    # Set properties for user root
    echo "SET .BASHRC FOR USER ROOT [/HOME/VAGRANT --> /ROOT/.BASHRC]"
    cp -f .bashrc /root/
    
    # source .bashrc
    echo "SOURCE /HOME/VAGRANT/.BASHRC"
    source /root/.bashrc
}

function set-storage(){    
    if [[ "$NODE_MASTER" == *"$NODE_NAME"* ]]; then
        echo "CONFIGURE STORAGE $(hostname -f)"
        
        # Deploy local-path-storage provisioner
        kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.24/deploy/local-path-storage.yaml
        
        # Create Storage Class NFS
        kubectl apply -f kubernetes/volumes/nfs-storageclass.yaml
        
        # Set default Storage Class
        #echo "SET DEFAULT STORAGE CLASS FOR NFS..."
        #kubectl patch storageclass nfs -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
    fi
}

# Main
init
install-rke2
set-network
set-rke2
set-tools
set-storage

# Check the health of the deployment by running a status command:
#kubectl get componentstatuses
#kubectl get nodes

# follow the logs, if you like
# journalctl -u rke2-server -f