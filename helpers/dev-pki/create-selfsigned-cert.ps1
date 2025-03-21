<#
.SYNOPSIS
   Create a new self-signed certificate for testing purposes.

.DESCRIPTION
   Create a new self-signed certificate for testing purposes.

.PARAMETER -CertName
   Define the name of your new certificate.
   For example "TestClient"

.PARAMETER -CertValidityYears
   Define the validity period of the new certificate in years.
   For example 2

.PARAMETER -Verbose
   Enable verbose output.

.EXAMPLE
   .\create-selfsigned-cert.ps1 -CertName "MyTestCert" -CertValidityYears 2

.OUTPUTS
   The script will create a new certificate in the current user's personal certificate store.
   Also it will export the certificate to a .cer file in the $env:TEMP\TestCerts folder.

.LINK
   https://github.com/niklasrst/graph-scripts/tree/main/helpers/dev-pki

.AUTHOR
   Niklas Rast
#>

param
(
    [Parameter(Mandatory=$true, HelpMessage='Define the name for the new certrificate')]
    [string]$CertName = "TEST cert",
    [Parameter(Mandatory=$true, HelpMessage='Define the validity period of the certificate')]
    [int]$CertValidityYears = 2
)

# Define the file paths for exported certificates
Write-Verbose "Create folder to export certs later..."
$CertFolder = "$env:TEMP\TestCerts"
New-Item -ItemType Directory -Path $CertFolder -Force | Out-Null

New-SelfSignedCertificate `
    -Subject "CN=$($CertName)" `
    -CertStoreLocation "cert:\CurrentUser\My" `
    -NotAfter (Get-Date).AddYears($CertValidityYears) `
    -KeySpec Signature `
    -KeyExportPolicy Exportable

$cert = Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.Subject -like "*$($CertName)*"}
Export-Certificate -Cert $cert -FilePath "$env:TEMP\TestCerts\$($CertName).cer"