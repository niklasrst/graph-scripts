<#
.SYNOPSIS
   Encode or decode a string to/from base64.

.DESCRIPTION
    This script allows you to encode or decode a string to/from base64.

.PARAMETER -encode
    Encode a string to base64.

.PARAMETER -decode
    Decode a base64 string.

.PARAMETER -Verbose
   Enable verbose output.

.EXAMPLE
   .\base64.ps1 -direction encode -string "Hello World"
   .\base64.ps1 -direction decode -string "SGVsbG8gV29ybGQ="

.LINK
   https://github.com/niklasrst/graph-scripts/tree/main/helpers/

.AUTHOR
   Niklas Rast
#>

param (
    [Parameter(Mandatory=$true, HelpMessage='Define if you want to encode or decode base64')]
    [ValidateSet("encode", "decode")]
    [string]$direction,
    [Parameter(Mandatory=$true, HelpMessage='Text or Base64 hash to encode/decode')]
    [string]$string
)

if ($direction -eq "encode") {
    [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($string))
} elseif ($direction -eq "decode") {
    [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($string))
} else {
    Write-Host "Invalid direction"
}