<#
.SYNOPSIS
   Configure ACLs for a given folder or file in the Windows filesystem.

.DESCRIPTION
    This script allows you to configure ACLs for a given folder or file in the Windows filesystem.
    You can add or remove ACL rules for a specific user with a specific permission.

.PARAMETER -path
    Define the path to the folder or file from which you want to modify the permissions.
    For example "C:\Temp" or "C:\Temp\test.txt".

.PARAMETER -permission
    Define the ACL permission to set.
    Supported values are "AppendData", "ChangePermissions", "CreateDirectories", "CreateFiles", "Delete", "DeleteSubdirectoriesAndFiles", "ExecuteFile", "FullControl", "ListDirectory", "Modify", "Read", "ReadAndExecute", "ReadAttributes", "ReadData", "ReadExtendedAttributes", "ReadPermissions", "Synchronize", "TakeOwnership", "Traverse", "Write", "WriteAttributes", "WriteData", "WriteExtendedAttributes".
    For example "FullControl".

.PARAMETER -action
    Define the action to perform.
    Supported values are "Allow", "Deny".
    For example "Allow".

.PARAMETER -username
    Define the username for which you want to set the ACL.
    The username must start with "domain\" or "azuread\".
    For example "domain\user" or "azuread\user

.PARAMETER -operation
    Define whether to add or remove the ACL rule.
    Supported values are "Add", "Remove".
    For example "Add".

.PARAMETER -Verbose
   Enable verbose output.

.EXAMPLE
   .\acl-configurator.ps1 -path C:\Data\temp\ -permission FullControl -action Allow -username azuread\user@domain.com -operation Add
   .\acl-configurator.ps1 -path "C:\Temp\test.txt" -permission "Read" -action "Allow" -username "domain\user" -operation Remove

.LINK
   https://github.com/niklasrst/graph-scripts/tree/main/helpers/windows-acl

.AUTHOR
   Niklas Rast
#>

param
(
    [Parameter(Mandatory=$true, HelpMessage='Define the path to the folder or file')]
    [ValidateScript({
        if (Test-Path -Path $_) {
            $true
        } else {
            throw "Path $_ does not exist."
        }
    })]
    [string]$path = "",
    [Parameter(Mandatory=$true, HelpMessage='Define the ACL permission to set')]
    [ValidateSet("AppendData", "ChangePermissions", "CreateDirectories", "CreateFiles", "Delete", "DeleteSubdirectoriesAndFiles", "ExecuteFile", "FullControl", "ListDirectory", "Modify", "Read", "ReadAndExecute", "ReadAttributes", "ReadData", "ReadExtendedAttributes", "ReadPermissions", "Synchronize", "TakeOwnership", "Traverse", "Write", "WriteAttributes", "WriteData", "WriteExtendedAttributes")]
    [string]$permission = "",
    [Parameter(Mandatory=$false, HelpMessage='Define the action to perform')]
    [ValidateSet("Allow", "Deny")]
    [string]$action = "",
    [Parameter(Mandatory=$true, HelpMessage='Specify the username which should start with domain\\ or azuread\\')]
    [string]$username,
    [Parameter(Mandatory=$true, HelpMessage='Specify whether to add or remove the ACL rule')]
    [ValidateSet("Add", "Remove")]
    [string]$operation
)

# Check if the script is run with administrator privileges
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
Write-Verbose "Running as $currentUser"
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "You need to run this script as an administrator."
} else {
    Write-Verbose "Running with administrator privileges."
}

# Variables
Write-Verbose "Settings: $Path, $permission, $action, $Username"
$acl = $null

# Define ACL rule
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, $permission, "ContainerInherit, ObjectInherit", "None", $action)
$acl = Get-Acl -Path $Path

switch ($operation) {
    "Add" {
        Write-Verbose "MODE $operation"
        Write-Verbose "Configuring ACL for $Username with $permission permission to $Path\$Filename in $action mode"
        $acl.SetAccessRule($rule)
     }
    "Remove" {
        Write-Verbose "MODE $operation"
        Write-Verbose "Removing ACL for $Username with $permission permission to $Path\$Filename"
        $acl.RemoveAccessRule($rule)
     }
    Default { Write-Host "Invalid operation" }
}

Set-Acl -Path $Path -AclObject $acl