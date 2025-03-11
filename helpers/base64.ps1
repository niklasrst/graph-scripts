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