# Vagrant Helps

## Issue erro ssh after package box

<https://github.com/hashicorp/vagrant/issues/5186>

Adicionar esta linha na build do box e nos boxes que forem usar esta build:
config.ssh.insert_key = false


## Create vagrant box

<https://www.engineyard.com/blog/building-a-vagrant-box-from-start-to-finish/>
<https://martincarstenbach.wordpress.com/2020/05/05/versioning-for-your-local-vagrant-boxes-adding-a-new-box/>

## Configure VM

First...Install packages, configure host,etc

## Install latest VBoxGuestAdditions

```sh
wget http://download.virtualbox.org/virtualbox/7.0.10/VBoxGuestAdditions_7.0.10.iso
sudo mkdir /media/VBoxGuestAdditions
sudo mount -o loop,ro VBoxGuestAdditions_7.0.10.iso /media/VBoxGuestAdditions
sudo sh /media/VBoxGuestAdditions/VBoxLinuxAdditions.run
rm VBoxGuestAdditions_7.0.10.iso
sudo umount /media/VBoxGuestAdditions
sudo rmdir /media/VBoxGuestAdditions
```

## Zero out the drive

Before you package the box, you’ll want to “zero out” the drive.\
According to Vagrant: Up and Running: “This fixes fragmentation issues with the underlying disk,\
which allows it to compress much more efficiently later.”

```sh
sudo dd if=/dev/zero of=/EMPTY bs=1M
sudo rm -f /EMPTY
```

## Packaging the base box

```sh
vagrant package --base infra-server01 --output silvestrini-rocky9.box
```

## Creating box metadata

```json
{
    "name": "silvestrini-rocky9",
    "description": "Silvestrini Rocky 9",
    "versions": [
      {
        "version": "9.1",
        "providers": [
          {
            "name": "virtualbox",
            "url": "file://e/Apps/Vagrant/vagrant.d/boxes/silvestrini-rocky9",
            "checksum": "D2E91C5296A228862F8ED5C9FAD7452AEE1776E480F3BFED35F57B8090D33540",
            "checksum_type": "sha256"
          }
        ]
      }
    ]
  } 
```

## Test the box

```sh
vagrant box add silvestrini-ol9 silvestrini-ol9.box
vagrant init ubuntu64
vagrant up
```
