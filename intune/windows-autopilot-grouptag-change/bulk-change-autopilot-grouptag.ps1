<#
.SYNOPSIS
   Update the GroupTag for Windows Autopilot devices in bulk.

.DESCRIPTION
    This script allows you to bulk change the GroupTag for Windows Autopilot devices.

.PARAMETER -oldGroupTag
    Define the old GroupTag that you want to change.

.PARAMETER -newGroupTag
    Define the new GroupTag.

.PARAMETER -Verbose
   Enable verbose output.

.EXAMPLE
   .\bulk-change-autopilot-grouptag.ps1 -oldGroupTag "GroupTag1" -newGroupTag "GroupTag2"

.LINK
   https://github.com/niklasrst/graph-scripts/tree/main/helpers/intune/windows-autopilot-grouptag-change

.AUTHOR
   Niklas Rast
#>

param (
    [Parameter(Mandatory=$true, HelpMessage='Enter the old GroupTag that you want to change')]
    [string]$oldGroupTag,
    [Parameter(Mandatory=$true, HelpMessage='Enter the new GroupTag')]
    [string]$newGroupTag
)

Connect-MgGraph

Write-Host "Devices with old GroupTag:"

Get-MgDeviceManagementWindowsAutopilotDeviceIdentity -All | Where-Object GroupTag -match "$oldGroupTag" | Select-Object -exp GroupTag | Group-Object | Select-Object count,name

Read-Host "Press Enter to continue"

Get-MgDeviceManagementWindowsAutopilotDeviceIdentity -All | Where-Object GroupTag -eq "$oldGroupTag" | ForEach-Object {
    Update-MgDeviceManagementWindowsAutopilotDeviceIdentityDeviceProperty -WindowsAutopilotDeviceIdentityId $_.Id -GroupTag "$newGroupTag"
}