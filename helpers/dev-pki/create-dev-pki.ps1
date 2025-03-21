<#
.SYNOPSIS
   Create a development/test PKI with a Root CA and Intermediate CA.

.DESCRIPTION
   Create a Root CA and Intermediate CA for development or testing purposes.
   Those then can be used to create different types of certificates to test array of scenarios.

.PARAMETER -RootCAName
    Define the name of your dev root ca.
    For example "CorpRootCA"

.PARAMETER -RootCAOrganization
    Define the name of your dev ca organization.
    For example "Corp"

.PARAMETER -RootCACountry
    Define the country of your dev root ca.
    For example "US"

.PARAMETER -IntermediateCAName
    Define the name of your dev intermediate ca.
    For example "Corp SCA"

.PARAMETER -RootCertValidityYears
    Define the validity period of your dev root ca.
    For example 10

.PARAMETER -IntermediateCertValidityYears
    Define the validity period of your dev intermediate ca.
    For example 10

.PARAMETER -Verbose
   Enable verbose output.

.EXAMPLE
    Create a RootCA named "CorpRootCA" with an issuing Intermediate CA named "Corp SCA" which is valid for 10 years and located in the country US.
    .\create-dev-pki.ps1 -RootCAName CorpRootCA -RootCAOrganization Corp -RootCACountry US -IntermediateCAName "Corp SCA" -RootCertValidityYears 10 -IntermediateCertValidityYears 10

.OUTPUTS
    The script will create a Root CA and Intermediate CA certificates and export them to "$env:TEMP\TestCerts".
    Also those certs will be imported to the Local Machine's Root and CA stores on your system to the issue more certificates.
    Use the create-dev-certs.ps1 script to create different types of certificates issued by the dev/test certification authorities.

.NOTES
    Use this pki creation script only within a development or test infrastructure. It is not meant to be used in production environments.

.LINK
    https://github.com/niklasrst/graph-scripts/tree/main/helpers/dev-pki

.AUTHOR
    Niklas Rast
#>

param
(
    [Parameter(Mandatory=$true, HelpMessage='Define the name of your dev root ca')]
    [string]$RootCAName = "TestRootCA",
    [Parameter(Mandatory=$true, HelpMessage='Define the name of your dev ca organization')]
    [string]$RootCAOrganization = "TestAG",
    [Parameter(Mandatory=$true, HelpMessage='Define the country of your dev root ca')]
    [string]$RootCACountry = "US",
    [Parameter(Mandatory=$true, HelpMessage='Define the name of your dev intermediate ca')]
    [string]$IntermediateCAName = "Test SCA",
    [Parameter(Mandatory=$true, HelpMessage='Define the validity period of your dev root ca')]
    [int]$RootCertValidityYears = 10,
    [Parameter(Mandatory=$true, HelpMessage='Define the validity period of your dev intermediate ca')]
    [int]$IntermediateCertValidityYears = 10
)   

# Define the file paths for exported certificates
Write-Verbose "Create folder to export certs later..."
$CertFolder = "$env:TEMP\TestCerts"
New-Item -ItemType Directory -Path $CertFolder -Force | Out-Null

# Create the Root CA certificate
Write-Host "Creating Root CA..."
$RootCert = New-SelfSignedCertificate -Type Custom -KeyUsageProperty Sign -KeyUsage CertSign, CRLSign `
   -Subject "CN=$RootCAName, O=$RootCAOrganization, C=$RootCACountry" -KeyAlgorithm RSA -KeyLength 4096 `
   -CertStoreLocation "Cert:\LocalMachine\My" -NotAfter (Get-Date).AddYears($RootCertValidityYears) `
   -HashAlgorithm SHA256

# Export Root CA certificate
$RootCertPath = "$CertFolder\$($RootCAName).cer"
Export-Certificate -Cert $RootCert -FilePath $RootCertPath | Out-Null
Write-Host "Root CA certificate saved to $RootCertPath"

# Import to Root
Write-Verbose "Importing Root CA certificate to Root store..."
Import-Certificate -FilePath $RootCertPath -CertStoreLocation "Cert:\LocalMachine\Root" | Out-Null

# Create Intermediate CA certificate signed by the Root CA
Write-Host "Creating Intermediate CA..."
$IntermediateCert = New-SelfSignedCertificate -Type Custom -KeyUsageProperty Sign -KeyUsage CertSign, CRLSign `
   -Subject "CN=$IntermediateCAName, O=$RootCAOrganization, C=$RootCACountry" -KeyAlgorithm RSA -KeyLength 4096 `
   -CertStoreLocation "Cert:\LocalMachine\My" -Signer $RootCert `
   -NotAfter (Get-Date).AddYears($IntermediateCertValidityYears) -HashAlgorithm SHA256
   # TODO: Add capability to issue trusted certificates

# Export Intermediate CA certificate
$IntermediateCertPath = "$CertFolder\$($IntermediateCAName).cer"
Export-Certificate -Cert $IntermediateCert -FilePath $IntermediateCertPath | Out-Null
Write-Host "Intermediate CA certificate saved to $IntermediateCertPath"

# Import to CA
Write-Verbose "Importing Intermediate CA certificate to CA store..."
Import-Certificate -FilePath $IntermediateCertPath -CertStoreLocation "Cert:\LocalMachine\CA" | Out-Null