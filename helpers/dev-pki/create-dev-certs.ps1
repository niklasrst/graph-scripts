<#
.SYNOPSIS
   Issue a new certificate from a development/test PKI.

.DESCRIPTION
   Issue "SSL", "UserAuth", "SmartCardAuth", "CodeSign", "ServerAuth", "ClientAuth" certificates from a development/test PKI.
   Those certificates can be used to test different scenarios in a development or test environment.

.PARAMETER -type
   Define the type of certificate to create.
   Supported values are "SSL", "UserAuth", "SmartCardAuth", "EmailProtection", "CodeSign", "ServerAuth", "ClientAuth".

.PARAMETER -CertName
   Define the name of your new certificate.
   For example "TestClient"

.PARAMETER -IntermediateCAName
   Define the name of the issuing intermediate CA that you created earlier.
   For example "Corp SCA"

.PARAMETER -CertValidityYears
   Define the validity period of the new certificate in years.
   For example 2

.PARAMETER -Verbose
   Enable verbose output.

.EXAMPLE
   .\create-dev-certs.ps1 -type SSL -CertName "TEST SSL" -IntermediateCAName "Corp SCA" -CertValidityYears 1
   .\create-dev-certs.ps1 -type UserAuth -CertName "TEST USER" -IntermediateCAName "Corp SCA" -CertValidityYears 2
   .\create-dev-certs.ps1 -type SmartCardAuth -CertName "TEST SMARTCARD" -IntermediateCAName "Corp SCA" -CertValidityYears 1
   .\create-dev-certs.ps1 -type EmailProtection -CertName "TEST EMAIL" -IntermediateCAName "Corp SCA" -CertValidityYears 1
   .\create-dev-certs.ps1 -type CodeSign -CertName "TEST CODE SIGN" -IntermediateCAName "Corp SCA" -CertValidityYears 2
   .\create-dev-certs.ps1 -type ServerAuth -CertName "TEST SERVER" -IntermediateCAName "Corp SCA" -CertValidityYears 1
   .\create-dev-certs.ps1 -type ClientAuth -CertName "TEST CLIENT" -IntermediateCAName "Corp SCA" -CertValidityYears 1

.OUTPUTS
   Use the create-dev-pki.ps1 script upfront to create the needed root and intermediate CAs.

.NOTES
   Use this certificate creation script only within a development or test infrastructure. It is not meant to be used in production environments.
   The certificates will be exported to "$env:TEMP\TestCerts" and can be used for testing purposes, the .pfx files are saved with the password from the $CertPFXPassword variable.

.LINK
   https://github.com/niklasrst/graph-scripts/tree/main/helpers/dev-pki

.AUTHOR
   Niklas Rast
#>

param
(
    [Parameter(Mandatory=$true, HelpMessage='Define the type of certificate to create')]
    [ValidateSet("SSL", "UserAuth", "SmartCardAuth", "EmailProtection", "CodeSign", "ServerAuth", "ClientAuth")]
    [string]$type,
    [Parameter(Mandatory=$true, HelpMessage='Define the name for the new certrificate')]
    [string]$CertName = "TEST cert",
    [Parameter(Mandatory=$true, HelpMessage='Define the CN of the issuing CA')]
    [string]$IntermediateCAName = "Corp SCA",
    [Parameter(Mandatory=$true, HelpMessage='Define the validity period of the certificate')]
    [int]$CertValidityYears = 2
)

Write-Verbose "Connverting password to secure string..."
$RandomPassword = -join ((65..90) + (97..122) + (48..57) + (33..47) | Get-Random -Count 12 | ForEach-Object {[char]$_})
$Password = ConvertTo-SecureString -String $RandomPassword -Force -AsPlainText

# Check if the Intermediate CA exists
$IntermediateCert = Get-ChildItem -Path "Cert:\LocalMachine\CA" | Where-Object { $_.Subject -like "*CN=$($IntermediateCAName)*" }
if (-not $IntermediateCert) {
    Write-Host "Intermediate CA certificate not found. Please create the Intermediate CA first."
    break
} else {
   Write-Verbose "Intermediate CA certificate found."
}

# Check if the Root CA exists
$RootCert = Get-ChildItem -Path "Cert:\LocalMachine\Root" | Where-Object { $_.Subject -like "*$($intermediateCert.Issuer)*" }
if (-not $RootCert) {
   Write-Host "Root CA certificate not found. Please create the Root CA first."
   break
} else {
   Write-Verbose "Root CA certificate found."
}

# Get CN, Org and Country from the Intermediate CA
$subjectArray = $intermediateCert.Subject -split ", "
$intermediateCertCN = $null
$intermediateCertOrg = $null
$intermediateCertCountry = $null

foreach ($item in $subjectArray) {
    if ($item -match "^CN=") {
        $intermediateCertCN = $item
    } elseif ($item -match "^O=") {
        $intermediateCertOrg = $item
    } elseif ($item -match "^C=") {
        $intermediateCertCountry = $item
    }
}

Write-Verbose "Creating $type certificate issued by $intermediateCertCN with a validity of $CertValidityYears years..."

# Define the file paths for exported certificates
Write-Verbose "Create folder to export certs later..."
$CertFolder = "$env:TEMP\TestCerts"
New-Item -ItemType Directory -Path $CertFolder -Force | Out-Null

# Function to create certificates from intermediate CA
function New-DevCertificate {
   param(
       [string]$CommonName,
       [string]$Usage,
       [string]$FileName,
       [string]$certStore
   )
   Write-Host "Creating $Usage certificate in $certStore ..."
   Write-Verbose "Certificate Details: CN=$CommonName, O=$intermediateCertOrg, C=$intermediateCertCountry"
   $Cert = New-SelfSignedCertificate -Type Custom `
       -Subject "CN=$CommonName, O=$intermediateCertOrg, C=$intermediateCertCountry" -KeyAlgorithm RSA -KeyLength 2048 `
       -CertStoreLocation $certStore -Signer $IntermediateCert `
       -NotAfter (Get-Date).AddYears($CertValidityYears) -HashAlgorithm SHA256 `
       -TextExtension @("2.5.29.37={text}$Usage")

   # Export the certificate and private key
   $CertPath = "$CertFolder\$FileName.pfx"
   Export-PfxCertificate -Cert $Cert -FilePath $CertPath -Password $Password | Out-Null
   Write-Host "$Usage certificate saved to $CertPath use $RandomPassword to access the private key"
}

# Generate end-entity certificates
switch ($type) {
   "SSL" { 
      # TLS/SSL Server Authentication
      Write-Verbose "Certificate type: SSL"
      New-DevCertificate -CommonName "$CertName" -Usage "1.3.6.1.5.5.7.3.1" -FileName "${CertName}-SSL"-certStore "Cert:\LocalMachine\My"
    }
   "UserAuth" { 
      # Code Signing
      Write-Verbose "Certificate type: UserAuth"
      New-DevCertificate -CommonName "$CertName" -Usage "1.3.6.1.5.5.7.3.2,1.3.6.1.4.1.311.20.2.2" -FileName "${CertName}-USER" -certStore "Cert:\CurrentUser\My"
    }
    "SmartCardAuth" {
      # Smart Card Authentication
      Write-Verbose "Certificate type: SmartCardAuth"
      New-DevCertificate -CommonName "$CertName" -Usage "1.3.6.1.4.1.311.20.2.2" -FileName "${CertName}-SMARTCARD" -certStore "Cert:\CurrentUser\My"
    }
    "EmailProtection" {
      # S/MIME Email Encryption & Signing
      Write-Verbose "Certificate type: EmailProtection"
      New-DevCertificate -CommonName "$CertName" -Usage "1.3.6.1.5.5.7.3.4" -FileName "${CertName}-EMAIL" -certStore "Cert:\CurrentUser\My"
    }
   "CodeSign" { 
      # User Authentication
      Write-Verbose "Certificate type: CodeSign"
      New-DevCertificate -CommonName "$CertName" -Usage "1.3.6.1.5.5.7.3.3" -FileName "${CertName}-CODESIGN" -certStore "Cert:\CurrentUser\My"
    }
   "ServerAuth" { 
      # S/MIME Email Encryption & Signing
      Write-Verbose "Certificate type: ServerAuth"
      New-DevCertificate -CommonName "$CertName" -Usage "1.3.6.1.5.5.7.3.1" -FileName "${CertName}-SERVER" -certStore "Cert:\LocalMachine\My"
    }
   "ClientAuth" { 
      # Client Authentication
      Write-Verbose "Certificate type: ClientAuth"
      New-DevCertificate -CommonName "$CertName" -Usage "1.3.6.1.5.5.7.3.2" -FileName "${CertName}-CLIENT" -certStore "Cert:\LocalMachine\My"
    }
   Default { Write-Host "Invalid certificate type" }
}