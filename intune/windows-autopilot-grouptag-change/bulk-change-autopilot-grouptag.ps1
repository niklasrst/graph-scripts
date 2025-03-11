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