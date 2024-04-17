<#
.DESCRIPTION
    Requirments: none
    Description: Script for build custom vagrant box silvestrini-rocky9
    Author: Marcos Silvestrini
    Date: 12/04/2024    
#>

# Execute script as Administrator
# if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {  
#    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
#    Start-Process -Wait powershell -Verb runAs -WindowStyle Minimized -ArgumentList $arguments
#    Break
# }

# Clear screen
Clear-Host

# Fix powershell error
$Env:VAGRANT_PREFER_SYSTEM_BIN += 0

# Set openssl
#set OPENSSL_CONF="C:\Program Files\Git\mingw64\etc\ssl\openssl.cnf"

# Variables
$vdiskmanager = "E:\Apps\VMWare\vmware-vdiskmanager.exe"
$scriptPath = ($PSScriptRoot | Split-Path -Parent)|Split-Path -Parent
$pathBuild="$scriptPath\builds\silvestrini-rocky9"
$customBoxName="silvestrini-rocky9"

# Up Vagrant VMWare Utility
#Get-Service -name VagrantVMware

# Fix scripts
& "C:\Program Files\Git\mingw64\bin\dos2unix.exe" $scriptPath\scripts\linux\commons\*
& "C:\Program Files\Git\mingw64\bin\dos2unix.exe" $scriptPath\scripts\linux\bind\*
& "C:\Program Files\Git\mingw64\bin\dos2unix.exe" $scriptPath\scripts\linux\load-balance\*
& "C:\Program Files\Git\mingw64\bin\dos2unix.exe" $scriptPath\scripts\linux\rke2\*

# Set Workdir
Set-Location $pathBuild

# Clear artefacts
vagrant box remove $customBoxName

# Create VM and customize
vagrant validate
vagrant up 
vagrant halt

# Package vagrant box

## Optimizing Box Size
$pathVM=(Get-ChildItem -Path .vagrant\machines\default\vmware_desktop -Directory).FullName
(Get-ChildItem -Path $pathVM -Recurse -Include @("*.vmdk")).FullName `
| ForEach-Object{
    & $vdiskmanager -R "$_"
    & $vdiskmanager -d "$_"
    & $vdiskmanager -k "$_"
}

## Delete trash files
(Get-ChildItem -Path $pathVM  -Recurse -Exclude @("*.nvram", "*.vmsd", "*.vmx", "*.vmxf","*.vmdk","*.json")).FullName `
| ForEach-Object{ 
    If($_ -ne $null){
        Remove-Item $_ -Recurse -Force
    }    
}

## Package files
Set-Location $pathVM
tar cvzf "$pathBuild/$customBoxName.box" ./*

# Add box for vagrant
vagrant box add "$pathBuild\$customBoxName.box" --provider vmware_desktop --name $customBoxName --force
Set-Location $pathBuild

# Destroy VM
Set-Location $pathBuild
vagrant destroy -f

# Clear artefacts
If(Test-Path "$pathBuild\$customBoxName.box"){Remove-Item -Force "$pathBuild/$customBoxName.box"}
