Connect-MgGraph -Scope "DeviceManagementConfiguration.ReadWrite.All" -NoWelcome -ErrorAction Stop

# Get all EPM Requests
$GetAllEPMRequestsUri = "https://graph.microsoft.com/beta/deviceManagement/elevationRequests"
$AllEPMRequests = Invoke-MgGraphRequest -Uri $GetAllEPMRequestsUri -Method Get

# Filter for pending requests
$PendingRequests = $AllEPMRequests.value | Where-Object { $_.status -eq "pending" }

# Display Pending EPM Requests in console
Write-Host "Pending EPM Requests:" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan

if ($PendingRequests.Count -eq 0) {
    Write-Host "No pending EPM requests found." -ForegroundColor Yellow
}
else {
    foreach ($request in $PendingRequests) {
        Write-Host "`nRequest ID: $($request.id)" -ForegroundColor Green
        Write-Host "Status: $($request.status)"
        Write-Host "Requested DateTime: $($request.requestCreatedDateTime)"
        Write-Host "Last Modified: $($request.requestLastModifiedDateTime)"
        Write-Host "Expiry DateTime: $($request.requestExpiryDateTime)"
        
        if ($request.deviceName) {
            Write-Host "Device Name: $($request.deviceName)"
        }
        
        Write-Host "Device ID: $($request.requestedOnDeviceId)"
        Write-Host "Requested By: $($request.requestedByUserPrincipalName) ($($request.requestedByUserId))"
        Write-Host "Justification: $($request.requestJustification)"
        
        if ($request.applicationDetail) {
            Write-Host "`nApplication Details:"
            Write-Host "  File Name: $($request.applicationDetail.fileName)"
            Write-Host "  File Path: $($request.applicationDetail.filePath)"
            Write-Host "  Publisher: $($request.applicationDetail.publisherName)"
            Write-Host "  Version: $($request.applicationDetail.productVersion)"
        }
        
        if ($request.reviewCompletedDateTime) {
            Write-Host "`nReview Completed: $($request.reviewCompletedDateTime)"
            Write-Host "Reviewed By: $($request.reviewCompletedByUserPrincipalName) ($($request.reviewCompletedByUserId))"
            Write-Host "Reviewer Justification: $($request.reviewerJustification)"
        }
    }
}

#region EPM Request Actions

$actionOptions = @("approve", "deny", "revoke")
$action = $null

while ($action -notin $actionOptions) {
    $action = Read-Host "Do you want to approve, deny, or revoke a request? (Enter 'approve', 'deny', or 'revoke')"
    if ($action -notin $actionOptions) {
        Write-Host "Invalid action. Please enter 'approve', 'deny', or 'revoke'." -ForegroundColor Red
    }
}
$requestId = Read-Host "Enter the request ID"

switch ($action) {
    "approve" {
        $approveUri = "https://graph.microsoft.com/beta/deviceManagement/elevationRequests/$requestId/approve"
        $approveBody = @{
            reviewerJustification = "Approved for business purposes"
        } | ConvertTo-Json

        $approveResponse = Invoke-MgGraphRequest -Uri $approveUri -Method POST -Body $approveBody -ContentType "application/json"
        Write-Host "Request $requestId approved successfully." -ForegroundColor Green
    }
    "deny" {
        $denyUri = "https://graph.microsoft.com/beta/deviceManagement/elevationRequests/$requestId/deny"
        $denyBody = @{
            reviewerJustification = "Denied due to security policy"
        } | ConvertTo-Json

        $denyResponse = Invoke-MgGraphRequest -Uri $denyUri -Method POST -Body $denyBody -ContentType "application/json"
        Write-Host "Request $requestId denied successfully." -ForegroundColor Yellow
    }
    "revoke" {
        $revokeUri = "https://graph.microsoft.com/beta/deviceManagement/elevationRequests/$requestId/revoke"
        $revokeBody = @{
            reviewerJustification = "Revoked due to changed circumstances"
        } | ConvertTo-Json

        $revokeResponse = Invoke-MgGraphRequest -Uri $revokeUri -Method POST -Body $revokeBody -ContentType "application/json"
        Write-Host "Request $requestId revoked successfully." -ForegroundColor Yellow
    }
    default {
        Write-Host "Invalid action. Please enter 'approve', 'deny', or 'revoke'." -ForegroundColor Red
    }
}

#endregion