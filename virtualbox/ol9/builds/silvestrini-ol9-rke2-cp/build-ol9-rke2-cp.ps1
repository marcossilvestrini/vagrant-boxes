<#
.DESCRIPTION
    Requirments: none
    Description: Script for build RKE2 Control Plane
    VaggrantBox: silvestrini-ol9
    Author: Marcos Silvestrini
    Date: 10/08/2023    
#>

# Execute script as Administrator
# if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {  
#    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
#    Start-Process -Wait powershell -Verb runAs -WindowStyle Minimized -ArgumentList $arguments
#    Break
# }

# Clear screen
Clear-Host

# Variables
$scriptPath = ($PSScriptRoot | Split-Path -Parent)|Split-Path -Parent
$pathBuildRKE2CP="$scriptPath\builds\silvestrini-ol9-rke2-cp"
$customBoxNameRKE2CP="silvestrini-ol9-rke2-cp"

# Set Workdir
Set-Location $pathBuildRKE2CP

# Fix scripts
& "C:\Program Files\Git\mingw64\bin\dos2unix.exe" $scriptPath\scripts\linux\commons\*
& "C:\Program Files\Git\mingw64\bin\dos2unix.exe" $scriptPath\scripts\linux\bind\*
& "C:\Program Files\Git\mingw64\bin\dos2unix.exe" $scriptPath\scripts\linux\load-balance\*
& "C:\Program Files\Git\mingw64\bin\dos2unix.exe" $scriptPath\scripts\linux\rke2\*

# Clear artefacts
vagrant box remove $customBoxNameRKE2CP
if(Test-Path "$pathBuildRKE2CP\$customBoxNameRKE2CP.box"){
    Remove-Item "$pathBuildRKE2CP\$customBoxNameRKE2CP.box" -Force
}

# Create VM and customize
vagrant validate
vagrant up

# Package vagrant box
vagrant package --base $customBoxNameRKE2CP --output "$pathBuildRKE2CP\$customBoxNameRKE2CP.box"

# Add box for vagrant
vagrant box add "$pathBuildRKE2CP\$customBoxNameRKE2CP.box" --name $customBoxNameRKE2CP

# Destroy VM
vagrant destroy -f

# Clear artifacts
If(Test-Path "$pathBuildRKE2CP\$customBoxNameRKE2CP.box"){Remove-Item -Force "$pathBuildRKE2CP\$customBoxNameRKE2CP.box"}