New-SelfSignedCertificate `
    -Subject "CN=AzureEnvironment" `
    -CertStoreLocation "cert:\CurrentUser\My" `
    -NotAfter (Get-Date).AddYears(2) `
    -KeySpec Signature `
    -KeyExportPolicy Exportable

$cert = Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.Subject -like "*AzureEnvironment*"}
Export-Certificate -Cert $cert -FilePath "C:\Data\AzureEnvironment.cer"