#!/bin/bash

<<'MULTILINE-COMMENT'
    Requirments: none
    Description: Script for set Storage NFS for Kubernetes clusters
    Author: Marcos Silvestrini
    Date: 31/02/2023
MULTILINE-COMMENT

# Set language/locale and encoding
export LANG=C

cd /home/vagrant || exit

echo "SET NFS FOR PV PROVISION..."

# Enable NFS services
systemctl enable rpcbind
systemctl enable nfs-server

# Set Storage (device /dev/sdX)
CHECK_SDA=$(lsblk |grep  sda1)
if [[ $CHECK_SDA == "" ]];
then
    DISK="/dev/sda"
else
    DISK="/dev/sdb"
    
fi

# create pv
pvcreate "$DISK"

# create vg
vgcreate vg_k8s "$DISK"

# create lv
lvcreate -l +100%FREE -n lv_k8s vg_k8s

# format lv with filesystem xfs
mkfs.xfs -f /dev/mapper/vg_k8s-lv_k8s

# Mount Share in /etc/fstab
#-rw-r--r-- 1 root root 652 Mar 24 10:25 /etc/fstab
VM=$(hostname)

## Copy original template for fstab
if [ ! -f "configs/commons/fstab_${VM}_backup" ]; then
    cp /etc/fstab "configs/commons/fstab_${VM}_backup"
fi

## Check fstab uuid
UUID_SERVER=$(echo $(cat /etc/fstab | grep "UUID=" | head -n 1) | cut -d' ' -f1)
UUID_LOCAL=$(echo $(cat "configs/commons/fstab_${VM}_backup" | grep "UUID=" | head -n 1) | cut -d' ' -f1)

if [ "$UUID_SERVER" = "$UUID_LOCAL" ]; then
    echo "UUIDS its ok for deploy"
    echo "UUID Server: $UUID_SERVER"
    echo "UUID Local: $UUID_LOCAL"
else
    echo "ERROR!!! UUIDS not equals."
    echo "We will Copy a nem /etc/fstab for deploy,relax guy!!!"
    rm "configs/commons/fstab_${VM}_backup"
    cp /etc/fstab "configs/commons/fstab_${VM}_backup"
fi

## Generate fstab with samba\cifs shares
if [ -f "configs/commons/fstab"  ];then
    rm "configs/commons/fstab"
fi
cp "configs/commons/fstab_${VM}_backup" configs/commons/fstab
cat configs/commons/template-fstab >> configs/commons/fstab
cp configs/commons/fstab /etc/fstab
dos2unix /etc/fstab
chmod 644 /etc/fstab  
systemctl daemon-reload

# Mount NFS Storage 
mkdir -p {/var/nfs,/var/nfs/app-silvestrini,/var/nfs/app-silvestrini/images}
chown -R vagrant:vagrant /var/nfs
umount /var/nfs 2>&1
mount /var/nfs

# Configure NFS
cp configs/nfs/exports /etc
dos2unix /etc/exports
chmod 644 /etc/exports
systemctl start rpcbind
systemctl start nfs-server
exportfs -arv

# Create the example 3 - My app - app-silvestrini
cp -R apps/app-silvestrini/images /var/nfs/app-silvestrini
cp apps/app-silvestrini/index.html /var/nfs/app-silvestrini
