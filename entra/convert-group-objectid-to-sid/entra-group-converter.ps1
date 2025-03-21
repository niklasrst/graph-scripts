<#
.SYNOPSIS
   Quickly convert a Entra Group ObjectID to a SID or a SID to a Entra Group ObjectID.

.DESCRIPTION
   Convert a Entra Group ObjectID to a SID or a SID to a Entra Group ObjectID.
   Enter the Entra Group ObjectID or SID and the direction you want to convert.

.PARAMETER -direction
   Define if you want to convert a Entra Group ObjectID to a SID or a SID to a Entra Group ObjectID.
   Valid values are "Object-to-Sid" and "Sid-to-Object".

.PARAMETER -id 
   Enter the Entra Group ObjectID or SID.

.PARAMETER -Verbose
   Enable verbose output.

.EXAMPLE
   .\entra-group-converter.ps1 -direction Object-to-Sid -id XXXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXX
   .\entra-group-converter.ps1 -direction Sid-to-Object -id S-1-12-X-X-XXXXXX

.LINK
   https://github.com/niklasrst/graph-scripts/tree/main/helpers/dev-pki

.AUTHOR
   Niklas Rast
#>

param (
    [Parameter(Mandatory=$true, HelpMessage='Define if you want to convert a Entra Group ObjectID to a SID or a SID to a Entra Group ObjectID')]
    [ValidateSet("Object-to-Sid", "Sid-to-Object")]
    [string]$direction,
    [Parameter(Mandatory=$true, HelpMessage='Enter the Entra Group ObjectID or SID')]
    [string]$id
)

switch ($direction) {
    Object-to-Sid { 
        $bytes = [Guid]::Parse($id).ToByteArray()
        $array = New-Object 'UInt32[]' 4
        [Buffer]::BlockCopy($bytes, 0, $array, 0, 16)
        $sid = "S-1-12-1-$array".Replace(' ', '-')
        Write-Verbose "Object: $id"
        Write-Output $sid
     }
    Sid-to-Object { 
        $text = $id.Replace('S-1-12-1-', '')
        $array = [UInt32[]]$text.Split('-')
        $bytes = New-Object 'Byte[]' 16
        [Buffer]::BlockCopy($array, 0, $bytes, 0, 16)
        [Guid]$guid = $bytes
        Write-Verbose "SID: $id"
        Write-Output $guid
     }
    Default {Write-Error "Invalid direction. Please choose between Object-to-Sid or Sid-to-Object"}
}
    