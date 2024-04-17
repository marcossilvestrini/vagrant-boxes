<#
.DESCRIPTION
    Requirments: none
    Description: Script for build NGINX LOADBALANCER
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
$pathBuildLB="$scriptPath\builds\silvestrini-ol9-lb"
$customBoxNameLB="silvestrini-ol9-lb"

# Set Workdir
Set-Location $pathBuildLB

# Fix scripts
& "C:\Program Files\Git\mingw64\bin\dos2unix.exe" $scriptPath\scripts\linux\commons\*
& "C:\Program Files\Git\mingw64\bin\dos2unix.exe" $scriptPath\scripts\linux\bind\*
& "C:\Program Files\Git\mingw64\bin\dos2unix.exe" $scriptPath\scripts\linux\load-balance\*
& "C:\Program Files\Git\mingw64\bin\dos2unix.exe" $scriptPath\scripts\linux\rke2\*

# Clear artefacts
vagrant box remove $customBoxNameLB
if(Test-Path "$pathBuildLB\$customBoxNameLB.box"){
    Remove-Item "$pathBuildLB\$customBoxNameLB.box" -Force
}

# Create VM and customize
vagrant validate
vagrant up

# Package vagrant box
vagrant package --base $customBoxNameLB --output "$pathBuildLB\$customBoxNameLB.box"

# Add box for vagrant
vagrant box add "$pathBuildLB\$customBoxNameLB.box" --name $customBoxNameLB

# Destroy VM
vagrant destroy -f

# Clear artifacts
If(Test-Path "$pathBuildLB\$customBoxNameLB.box"){Remove-Item -Force "$pathBuildLB\$customBoxNameLB.box"}