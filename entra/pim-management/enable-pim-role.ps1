<#
.SYNOPSIS
   Enable Entra ID PIM roles with reason and duration from Powershell.

.DESCRIPTION
   Use this script to enable Entra ID PIM roles with reason and duration from Powershell.
   No need to use the Azure Portal for this task.

.PARAMETER -RoleName
   Define the role name to activate.
   Supported values are "Intune Administrator", "Teams Administrator", "Global Reader", "Edge Administrator".

.PARAMETER -Reason
   Set the reason for the activation.
   For example "Daily operations".

.PARAMETER -duration
   Define the duration in hours for the activation.
   For example "2"

.PARAMETER -Verbose
   Enable verbose output.

.EXAMPLE
   .\enable-pim-role.ps1 -RoleName "Intune Administrator" -Reason "Daily operations" -duration 2

.LINK
   https://github.com/niklasrst/graph-scripts/tree/main/entra/pim-management

.AUTHOR
   Niklas Rast
#>

param (
    [Parameter()]
    [ValidateSet("Intune Administrator", "Teams Administrator", "Global Reader", "Edge Administrator")]
    [string]$RoleName = "",
    [Parameter()]
    [string]$Reason = "",
    [Parameter()]
    [int]$duration = 1
)

Write-Verbose "Role specs to activate: $RoleName, $Reason, $duration"

# Required Graph API permissions for app functionality
$mgGraphVersion = "beta"
$requiredPermissions = @(
)

try {
    $permissionsList = $requiredPermissions -join ', '
    Write-Verbose "Connecting to Microsoft Graph ($mgGraphVersion) with permissions: $permissionsList"
    Connect-MgGraph -Scopes $permissionsList -NoWelcome -ErrorAction Stop
    Write-Host "Successfully connected to Microsoft Graph using interactive sign-in." -ForegroundColor Green
}
catch {
    Write-Host "Failed to connect to Microsoft Graph via interactive sign-in. Error: $_" -ForegroundColor Red
    break
}

# Check and display the current permissions
$context = Get-MgContext
Write-Verbose "Microsoft Graph context: $context"
$currentPermissions = $context.Scopes
Write-Verbose "Microsoft Graph permissions: $currentPermissions"

# Validate required permissions
$missingPermissions = $requiredPermissions | Where-Object { $_ -notin $currentPermissions }
if ($missingPermissions.Count -gt 0) {
    Write-Host "WARNING: The following permissions are missing:" -ForegroundColor Red
    $missingPermissions | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
    Write-Host "Please ensure these permissions are granted to the app registration for full functionality." -ForegroundColor Yellow
    break
}

Write-Host "All required permissions are present." -ForegroundColor Green

# Get Role
$roleDefenitionsUrl = "https://graph.microsoft.com/$mgGraphVersion/roleManagement/directory/roleDefinitions"
Write-Verbose "Getting role definitions from $roleDefenitionsUrl"
$roleDefenitions = (Invoke-MgGraphRequest -Method GET -Uri $roleDefenitionsUrl).value
$roleDefinition = $roleDefenitions | Where-Object displayName -eq "$RoleName"
if (-not $roleDefinition) {
   Write-Host "Role '$RoleName' not found!" -ForegroundColor Red
   break
}

# Get Currently active Role Assignment
$roleAssignmentsUrl = "https://graph.microsoft.com/$mgGraphVersion/roleManagement/directory/roleAssignments"
Write-Verbose "Getting role assignments from $roleAssignmentsUrl"
$roleAssignments = (Invoke-MgGraphRequest -Method GET -Uri $roleAssignmentsUrl).value
$roleAssignment = $roleAssignments | Where-Object roleDefinitionId -eq $roleDefinition.id
if (-not $roleAssignment) {
   Write-Host "No active PIM assignment found for role '$roleName'"
   break
}

# Activate the Role
$activationUrl = "https://graph.microsoft.com/$mgGraphVersion/roleManagement/directory/roleEligibilityScheduleRequests"
Write-Verbose "Activating role '$roleName' with reason '$reason' for $duration hours."
$startTime = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
Write-Verbose "Activation start time: $startTime"
$endTime = (Get-Date).ToUniversalTime().AddHours($duration).ToString("yyyy-MM-ddTHH:mm:ssZ")
Write-Verbose "Activation end time: $endTime"
$activationBody = @{
   action                 = "selfActivate"
   justification          = $Reason
   principalId            = $roleAssignment.principalId
   roleDefinitionId       = $roleDefinition.id
   directoryScopeId       = $roleAssignment.directoryScopeId
   scheduleInfo           = @{
       startDateTime = $startTime
       endDateTime   = $endTime
   }
} | ConvertTo-Json -Depth 3
$roleActivation = (Invoke-MgGraphRequest -Method POST -Uri $activationUrl -Body $activationBody -ContentType "application/json").value

if ($roleActivation) {
   Write-Host "Successfully activated '$roleName' for $duration hours with reason '$reason'." -ForegroundColor Green
} else {
   Write-Host "Failed to activate role '$roleName'." -ForegroundColor Red
}

Disconnect-MgGraph | Out-Null