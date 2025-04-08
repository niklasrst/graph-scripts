<#
.SYNOPSIS
   Set static IPs to Windows 365 Cloud PC NICs in Azure Network Connection.

.DESCRIPTION
    This script allows you to configure fixed IP addresses for Windows 365 Cloud PC NICs in Azure Network Connection.
    The script will search for the NIC with the specified Cloud PC name and set the IP address to static.

.PARAMETER -cloudPCName
    Define the name of the Cloud PC for which you want to set the static IP address.

.PARAMETER -Verbose
   Enable verbose output.

.EXAMPLE
   .\assign-static-ip.ps1 -cloudPCName "CPC000ABCDEF"

.LINK
   https://github.com/niklasrst/graph-scripts/tree/main/helpers/windows-365

.AUTHOR
   Niklas Rast
#>

[CmdletBinding()] 
param (
    [Parameter(Mandatory=$true, HelpMessage='Name of the Cloud PC')]
    [string]$cloudPCName = "CPC000ABCDEF"
)

$resourceGroupName = "rg-cloudpcs"

Connect-AzAccount | Out-Null

$nic = Get-AzNetworkInterface | Where-Object { $_.ResourceGroupName -eq $resourceGroupName -and $_.Name -like "$cloudPCName*" }
Write-Verbose "Found NIC: $nic.Name"
Write-Verbose "Current IP configuration: $($nic.IpConfigurations.PrivateIpAddress) ("$nic.IpConfigurations.PrivateIpAllocationMethod")"

if ($null -ne $nic) {

} else {
    Write-Output "No NIC found for the specified Cloud PC name."
}