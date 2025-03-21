# 📃 PKI and Certificates for TESTING📃

This scripts can be used to create a dev/test PKI with Intermediate CA to issue certificates locally if needed.
Also there is a script to easily create self-signed certificates for example to use with Azure App registrations.

## How to?

Download the script and use it like in those examples.

### Create PKI and Intermediate CA
```powershell 
.\create-dev-pki.ps1 -RootCAName CorpRootCA -RootCAOrganization Corp -RootCACountry US -IntermediateCAName "Corp SCA" -RootCertValidityYears 10 -IntermediateCertValidityYears 10
```
The script will write the SID for the given ObjectID as the result.

### Use Intermediate CA to isse certs
```powershell 
.\create-dev-certs.ps1 -type SSL -CertName "TEST SSL" -IntermediateCAName "Corp SCA" -CertValidityYears 1

.\create-dev-certs.ps1 -type UserAuth -CertName "TEST USER" -IntermediateCAName "Corp SCA" -CertValidityYears 2

.\create-dev-certs.ps1 -type SmartCardAuth -CertName "TEST SMARTCARD" -IntermediateCAName "Corp SCA" -CertValidityYears 1

.\create-dev-certs.ps1 -type EmailProtection -CertName "TEST EMAIL" -IntermediateCAName "Corp SCA" -CertValidityYears 1

.\create-dev-certs.ps1 -type CodeSign -CertName "TEST CODE SIGN" -IntermediateCAName "Corp SCA" -CertValidityYears 2

.\create-dev-certs.ps1 -type ServerAuth -CertName "TEST SERVER" -IntermediateCAName "Corp SCA" -CertValidityYears 1

.\create-dev-certs.ps1 -type ClientAuth -CertName "TEST CLIENT" -IntermediateCAName "Corp SCA" -CertValidityYears 1
```

### Create a self-signed certificate for a Entra ID app registration
```powershell 
.\create-selfsigned-cert.ps1 -CertName "MyTestCert" -CertValidityYears 2
```

## 🤝 Contributing

Before making your first contribution please see the following guidelines:
1. [Semantic Commit Messages](https://gist.github.com/joshbuchea/6f47e86d2510bce28f8e7f42ae84c716)
1. [Git Tutorials](https://www.youtube.com/playlist?list=PLu-nSsOS6FRIg52MWrd7C_qSnQp3ZoHwW)
1. [Create a PR from a pushed branch](https://learn.microsoft.com/en-us/azure/devops/repos/git/pull-requests?view=azure-devops&tabs=browser#from-a-pushed-branch)


---

Made with ❤️ by [Niklas Rast](https://github.com/niklasrst)