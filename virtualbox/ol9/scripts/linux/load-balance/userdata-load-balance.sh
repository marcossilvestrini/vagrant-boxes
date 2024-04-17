#!/bin/bash

<<'MULTILINE-COMMENT'
    Requirments: none
    Description: Script for configure NGINX
    Author: Marcos Silvestrini
    Date: 14/04/2023
MULTILINE-COMMENT

export LANG=C

cd /home/vagrant || exit

# Install Nginx
dnf install -y nginx-mod-stream
dnf install -y nginx

# # Tunning Nginx

# # Configure /etc/nginx/nginx.conf
# #-rw-r--r--. 1 root root 2334 Oct  6 18:24 /etc/nginx/nginx.conf
# cp -f configs/load-balance/nginx.conf /etc/nginx/
# dos2unix /etc/nginx/nginx.conf
# chmod 644 /etc/nginx/nginx.conf

# # Check nginx configuration
# nginx -t

# # Enable ngix service
# systemctl enable nginx

# # Restart ngix service
# systemctl restart nginx
