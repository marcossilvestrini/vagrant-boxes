<#
.DESCRIPTION
    Requirments: none
    Description: Script for build custom vagrant box silvestrini-ol9
    Author: Marcos Silvestrini
    Date: 09/08/2023    
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

# # Variables
$scriptPath = ($PSScriptRoot | Split-Path -Parent)|Split-Path -Parent
$pathBuild="$scriptPath\builds\silvestrini-ol9"
$customBoxName="silvestrini-ol9"

# Fix scripts
& "C:\Program Files\Git\mingw64\bin\dos2unix.exe" $scriptPath\scripts\linux\commons\*
& "C:\Program Files\Git\mingw64\bin\dos2unix.exe" $scriptPath\scripts\linux\bind\*
& "C:\Program Files\Git\mingw64\bin\dos2unix.exe" $scriptPath\scripts\linux\load-balance\*
& "C:\Program Files\Git\mingw64\bin\dos2unix.exe" $scriptPath\scripts\linux\rke2\*

# Set Workdir
Set-Location $pathBuild

# Clear artefacts
vagrant box remove $customBoxName
if(Test-Path "$pathBuild\$customBoxName.box"){
    Remove-Item "$pathBuild\$customBoxName.box" -Force
}

# Create VM and customize
vagrant validate
vagrant up 

# Package vagrant box
vagrant package --base $customBoxName --output "$pathBuild\$customBoxName.box"

# Add box for vagrant
vagrant box add "$pathBuild\$customBoxName.box" --name $customBoxName

# Destroy VM
vagrant destroy -f

# Clear artifacts
If(Test-Path "$pathBuild\$customBoxName.box"){Remove-Item -Force "$pathBuild\$customBoxName.box"}