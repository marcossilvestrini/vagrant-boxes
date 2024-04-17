<#
.DESCRIPTION
    Requirments: none
    Description: Script for build all custom vagrant box 
    Author: Marcos Silvestrini
    Date: 08/09/2023    
#>

# Variables
$scriptPath = "$PSScriptRoot\builds"

# Get all VM names
$vmNames = VBoxManage list vms | ForEach-Object { $_ -match '"([^"]+)"'; $matches[1] }

# Delete each VM
foreach ($vmName in $vmNames) {
    Write-Host "Deleting VM: $vmName"
    VBoxManage unregistervm $vmName --delete
}

Write-Host "All VMs have been deleted."

# Build silvestrini-ol9
$arguments="$scriptPath\silvestrini-ol9\build-ol9.ps1"
Start-Process -Wait powershell -Verb runAs -WindowStyle Normal -ArgumentList $arguments

# build silvestrini-ol9-dns
$arguments="$scriptPath\silvestrini-ol9-dns\build-ol9-dns.ps1"
Start-Process -Wait powershell -Verb runAs -WindowStyle Normal -ArgumentList $arguments

# build silvestrini-ol9-lb
$arguments="$scriptPath\silvestrini-ol9-lb\build-ol9-lb.ps1"
Start-Process -Wait powershell -Verb runAs -WindowStyle Normal -ArgumentList $arguments

# build silvestrini-ol9-mgt
$arguments="$scriptPath\silvestrini-ol9-mgt\build-ol9-mgt.ps1"
Start-Process -Wait powershell -Verb runAs -WindowStyle Normal -ArgumentList $arguments

# build silvestrini-ol9-rke2-cp
$arguments="$scriptPath\silvestrini-ol9-rke2-cp\build-ol9-rke2-cp.ps1"
Start-Process -Wait powershell -Verb runAs -WindowStyle Normal -ArgumentList $arguments

# build silvestrini-ol9-rke2-wk
$arguments="$scriptPath\silvestrini-ol9-rke2-wk\build-ol9-rke2-wk.ps1"
Start-Process -Wait powershell -Verb runAs -WindowStyle Normal -ArgumentList $arguments
