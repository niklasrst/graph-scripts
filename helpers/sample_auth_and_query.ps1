# Authentication START
# App registration details required for certificate-based authentication
$appid = '<YourAppIdHere>' # Enterprise App (Service Principal) App ID
$tenantid = '<YourTenantIdHere>' # Your tenant ID
$certThumbprint = '<YourCertificateThumbprintHere>' # Certificate thumbprint from your certificate store

# Required Graph API permissions for app functionality
$requiredPermissions = @(
    "DeviceManagementApps.Read.All"
)

# Check if App ID, Tenant ID, or Certificate Thumbprint are set correctly
if (-not $appid -or $appid -eq '<YourAppIdHere>' -or
    -not $tenantid -or $tenantid -eq '<YourTenantIdHere>' -or
    -not $certThumbprint -or $certThumbprint -eq '<YourCertificateThumbprintHere>') {
    
    Write-Host "App ID, Tenant ID, or Certificate Thumbprint is missing or not set correctly." -ForegroundColor Red
    
    # Fallback to interactive sign-in if certificate-based authentication details are not provided
    $manualConnection = Read-Host "Would you like to attempt a manual interactive connection? (y/n)"
    if ($manualConnection -eq 'y') {
        Write-Host "Attempting manual interactive connection..." -ForegroundColor Yellow
        try {
            $permissionsList = $requiredPermissions -join ', '
            $connectionResult = Connect-MgGraph -Scopes $permissionsList -NoWelcome -ErrorAction Stop
            Write-Host "Successfully connected to Microsoft Graph using interactive sign-in." -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to connect to Microsoft Graph via interactive sign-in. Error: $_" -ForegroundColor Red
            exit
        }
    }
    else {
        Write-Host "Script execution cancelled by user." -ForegroundColor Red
        exit
    }
}
else {
    # Connect to Microsoft Graph using certificate-based authentication
    try {
        $connectionResult = Connect-MgGraph -ClientId $appid -TenantId $tenantid -CertificateThumbprint $certThumbprint -NoWelcome -ErrorAction Stop
        Write-Host "Successfully connected to Microsoft Graph using certificate-based authentication." -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to connect to Microsoft Graph. Error: $_" -ForegroundColor Red
        exit
    }
}

# Check and display the current permissions
$context = Get-MgContext
$currentPermissions = $context.Scopes

# Validate required permissions
$missingPermissions = $requiredPermissions | Where-Object { $_ -notin $currentPermissions }
if ($missingPermissions.Count -gt 0) {
    Write-Host "WARNING: The following permissions are missing:" -ForegroundColor Red
    $missingPermissions | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
    Write-Host "Please ensure these permissions are granted to the app registration for full functionality." -ForegroundColor Yellow
    exit
}

Write-Host "All required permissions are present." -ForegroundColor Green

# Auhentication END

# GET all apps START
#$fileStatusUri = "https://graph.microsoft.com/beta/deviceAppManagement/mobileApps"
#(Invoke-MgGraphRequest -Method GET -Uri $fileStatusUri).value
# GET all apps END

# GET all CPCs START
$fileStatusUri = "https://graph.microsoft.com/beta/deviceManagement/virtualEndpoint/cloudPCs"
(Invoke-MgGraphRequest -Method GET -Uri $fileStatusUri).value
# GET all CPCs END

# Disconnect START
Disconnect-MgGraph | Out-Null
# Disconnect END