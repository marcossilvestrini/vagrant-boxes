<#
.DESCRIPTION
    Requirments: none
    Description: Script for build all custom vagrant box 
    Author: Marcos Silvestrini
    Date: 16/04/2023    
#>

# Variables
$scriptPath = "$PSScriptRoot\builds"

# Build silvestrini-rocky9
$arguments="$scriptPath\silvestrini-rocky9\build-rocky9.ps1"
Start-Process -Wait powershell -Verb runAs -WindowStyle Normal -ArgumentList $arguments

# build silvestrini-rocky9-dns
$arguments="$scriptPath\silvestrini-rocky9-dns\build-rocky9-dns.ps1"
Start-Process -Wait powershell -Verb runAs -WindowStyle Normal -ArgumentList $arguments

# build silvestrini-rocky9-lb
$arguments="$scriptPath\silvestrini-rocky9-lb\build-rocky9-lb.ps1"
Start-Process -Wait powershell -Verb runAs -WindowStyle Normal -ArgumentList $arguments

# build silvestrini-rocky9-mgt
$arguments="$scriptPath\silvestrini-rocky9-mgt\build-rocky9-mgt.ps1"
Start-Process -Wait powershell -Verb runAs -WindowStyle Normal -ArgumentList $arguments

# build silvestrini-rocky9-rke2-cp
$arguments="$scriptPath\silvestrini-rocky9-rke2-cp\build-rocky9-rke2-cp.ps1"
Start-Process -Wait powershell -Verb runAs -WindowStyle Normal -ArgumentList $arguments

# build silvestrini-rocky9-rke2-wk
$arguments="$scriptPath\silvestrini-rocky9-rke2-wk\build-rocky9-rke2-wk.ps1"
Start-Process -Wait powershell -Verb runAs -WindowStyle Normal -ArgumentList $arguments
