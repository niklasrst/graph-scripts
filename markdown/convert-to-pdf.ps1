<#
.SYNOPSIS
    This script uses Pandoc to convert a Markdown file to PDF format using the Chrome engine.

.DESCRIPTION
    This PowerShell script converts a Markdown file to PDF format using Pandoc and the Chrome engine.
    It requires Pandoc and Google Chrome to be installed on the system. If the requirements are not met,
    the script will exit with an error message.

.PARAMETER -MDFilePath
    The path to the Markdown file that you want to convert to PDF.
    Example: "C:\path\to\file.md"

.PARAMETER -PDFSavePath
    The path where the resulting PDF file will be saved.
    Example: "C:\path\to\output.pdf"

.PARAMETER -Verbose
    Enable verbose output.

.EXAMPLE
    .\convert-to-pdf.ps1 -MDFilePath "C:\path\to\file.md" -PDFSavePath "C:\path\to\output.pdf"

.NOTES
    This script requires Pandoc and Google Chrome to be installed on the system.
    Ensure that the paths to these executables are correctly set in the script if they are not in the system PATH.
    Pandoc can be installed from https://pandoc.org/installing.html or using `winget install pandoc`.
    Google Chrome can be downloaded from https://www.google.com/chrome/ or installed using `winget install googlechrome`.

.LINK
    https://github.com/niklasrst/graph-scripts

.AUTHOR
   Niklas Rast
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateScript({
        if ((Test-Path $_ -PathType Leaf) -and $_.EndsWith('.md')) {
            return $true
        } else {
            throw "Could not find the defined markdown file. Insert filepath in the format 'C:\path\to\input.md'"
        }
    })]
    [string]$MDFilePath,
    [Parameter(Mandatory=$true)]
    [ValidateScript({
        if ($_ -match '^[a-zA-Z]:\\(?:[^\\/:*?"<>|\r\n]+\\)*[^\\/:*?"<>|\r\n]+\.pdf$') {
            return $true
        } else {
            throw "Output file path is not valid. Path must be in the format 'C:\path\to\output.pdf'"
        }
    })]
    [string]$PDFSavePath
)

# Prequisites check
if (-not (Get-Command pandoc -ErrorAction SilentlyContinue)) {
    Write-Error "Pandoc is not installed. Please install Pandoc from https://pandoc.org/installing.html or use winget install pandoc"
    exit 1
}
if (-not (Get-Command "C:\Program Files\Google\Chrome\Application\chrome.exe" -ErrorAction SilentlyContinue)) {
    Write-Error "Google Chrome is not installed. Please install Google Chrome from https://www.google.com/chrome/ or use winget install googlechrome"
    exit 1
}

# Convert Markdown to PDF
$TempSavePath = [System.IO.Path]::ChangeExtension($PDFSavePath, ".html")
Start-Process -FilePath "pandoc" -ArgumentList "$MDFilePath -o $TempSavePath" -PassThru -NoNewWindow -Wait | Out-Null

Start-Process -FilePath "C:\Program Files\Google\Chrome\Application\chrome.exe" -ArgumentList "--headless", "--disable-gpu", "--print-to-pdf=$PDFSavePath", "$TempSavePath" -PassThru -NoNewWindow -Wait | Out-Null

if (!(Test-Path $PDFSavePath)) {
    Write-Error "Failed to create PDF."
    exit 1
}

Remove-Item -Path $TempSavePath -Force