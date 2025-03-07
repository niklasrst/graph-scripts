# 🔀 ObjectID and SID Converter 🔀

This script can be used to convert Entra ID Object IDs to Windows SIDs and vice versa. <br>
Its based on [Oliver Kieselbach`s script](https://oliverkieselbach.com/2020/05/13/powershell-helpers-to-convert-azure-ad-object-ids-and-sids/).

## How to?

Download the script and use it like in those examples.

### Entra ObjectID to SID
ObjectIDs for Entra ID groups can be found in the Entra portal.
```powershell 
.\entra-group-converter.ps1 -direction Object-to-Sid -id S-00-00-0-000000000-000000000-000000000-000000000
```
The script will write the SID for the given ObjectID as the result.

### Entra SID to ObjectID
SIDs can be found on your Windows client using the `Get-LocalGroupMember -Group XXXXXXXX` command or in the Local users and groups blade of Computermanagement.
```powershell 
.\entra-group-converter.ps1 -direction Sid-to-Object -id S-00-00-0-000000000-000000000-000000000-000000000
```
The script will write the ObjectID for the given SID as the result.

## 🤝 Contributing

Before making your first contribution please see the following guidelines:
1. [Semantic Commit Messages](https://gist.github.com/joshbuchea/6f47e86d2510bce28f8e7f42ae84c716)
1. [Git Tutorials](https://www.youtube.com/playlist?list=PLu-nSsOS6FRIg52MWrd7C_qSnQp3ZoHwW)
1. [Create a PR from a pushed branch](https://learn.microsoft.com/en-us/azure/devops/repos/git/pull-requests?view=azure-devops&tabs=browser#from-a-pushed-branch)


---

Made with ❤️ by [Niklas Rast](https://github.com/niklasrst)