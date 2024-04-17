<#
.DESCRIPTION
    Requirments: none
    Description: Script for build RKE2 as Agent\Worker
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
$pathBuildRKE2WK="$scriptPath\builds\silvestrini-ol9-rke2-wk"
$customBoxNameRKE2WK="silvestrini-ol9-rke2-wk"

# Set Workdir
Set-Location $pathBuildRKE2WK

# Fix scripts
& "C:\Program Files\Git\mingw64\bin\dos2unix.exe" $scriptPath\scripts\linux\commons\*
& "C:\Program Files\Git\mingw64\bin\dos2unix.exe" $scriptPath\scripts\linux\bind\*
& "C:\Program Files\Git\mingw64\bin\dos2unix.exe" $scriptPath\scripts\linux\load-balance\*
& "C:\Program Files\Git\mingw64\bin\dos2unix.exe" $scriptPath\scripts\linux\rke2\*

# Clear artefacts
vagrant box remove $customBoxNameRKE2WK
if(Test-Path "$pathBuildRKE2WK\$customBoxNameRKE2WK.box"){
    Remove-Item "$pathBuildRKE2WK\$customBoxNameRKE2WK.box" -Force
}

# Create VM and customize
vagrant validate
vagrant up

# Package vagrant box
vagrant package --base $customBoxNameRKE2WK --output "$pathBuildRKE2WK\$customBoxNameRKE2WK.box"

# Add box for vagrant
vagrant box add "$pathBuildRKE2WK\$customBoxNameRKE2WK.box" --name $customBoxNameRKE2WK

# Destroy VM
vagrant destroy -f

# Clear artifacts
If(Test-Path "$pathBuildRKE2WK\$customBoxNameRKE2WK.box"){Remove-Item -Force "$pathBuildRKE2WK\$customBoxNameRKE2WK.box"}