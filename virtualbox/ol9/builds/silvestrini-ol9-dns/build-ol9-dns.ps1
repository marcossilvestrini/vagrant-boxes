<#
.DESCRIPTION
    Requirments: none
    Description: Script for build Bind DNS server
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
$pathBuildDNS="$scriptPath\builds\silvestrini-ol9-dns"
$customBoxNameDNS="silvestrini-ol9-dns"

# Set Workdir
Set-Location $pathBuildDNS

# Fix scripts
& "C:\Program Files\Git\mingw64\bin\dos2unix.exe" $scriptPath\scripts\linux\commons\*
& "C:\Program Files\Git\mingw64\bin\dos2unix.exe" $scriptPath\scripts\linux\bind\*
& "C:\Program Files\Git\mingw64\bin\dos2unix.exe" $scriptPath\scripts\linux\load-balance\*
& "C:\Program Files\Git\mingw64\bin\dos2unix.exe" $scriptPath\scripts\linux\rke2\*

# Clear artefacts
vagrant box remove $customBoxNameDNS
if(Test-Path "$pathBuildDNS\$customBoxNameDNS.box"){
    Remove-Item "$pathBuildDNS\$customBoxNameDNS.box" -Force
}

# Create VM and customize
vagrant validate
vagrant up

# Package vagrant box
vagrant package --base $customBoxNameDNS --output "$pathBuildDNS\$customBoxNameDNS.box"

# Add box for vagrant
vagrant box add "$pathBuildDNS\$customBoxNameDNS.box" --name $customBoxNameDNS

# Destroy VM
vagrant destroy -f

# Clear artifacts
If(Test-Path "$pathBuildDNS\$customBoxNameDNS.box"){Remove-Item -Force "$pathBuildDNS\$customBoxNameDNS.box"}