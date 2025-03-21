# 🚨 Windows ACL Configurator 🚨

This script can be used to set or remove acl rules to files or folders on a Windows filesystem.

## How to?

Download the script and use it like in those examples.

### Set ACL rules
```powershell 
.\acl-configurator.ps1 -path C:\Data\temp\ -permission FullControl -action Allow -username azuread\user@domain.com -operation Add
```

### Remove ACL rules
```powershell 
.\acl-configurator.ps1 -path "C:\Temp\test.txt" -permission "Read" -action "Allow" -username "domain\user" -operation Remove
```


## 🤝 Contributing

Before making your first contribution please see the following guidelines:
1. [Semantic Commit Messages](https://gist.github.com/joshbuchea/6f47e86d2510bce28f8e7f42ae84c716)
1. [Git Tutorials](https://www.youtube.com/playlist?list=PLu-nSsOS6FRIg52MWrd7C_qSnQp3ZoHwW)
1. [Create a PR from a pushed branch](https://learn.microsoft.com/en-us/azure/devops/repos/git/pull-requests?view=azure-devops&tabs=browser#from-a-pushed-branch)


---

Made with ❤️ by [Niklas Rast](https://github.com/niklasrst)