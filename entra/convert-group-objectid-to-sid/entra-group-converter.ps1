<#
    .SYNOPSIS 
    Converts between Entra Group ObjectID and SID

    .DESCRIPTION
    Use this script to convert between Entra Group ObjectID and SID.
    Sample usage is .\entra-group-converter.ps1 -direction XXXX -id XXXX
    
    .ENVIRONMENT
    PowerShell 5.0
    
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
    