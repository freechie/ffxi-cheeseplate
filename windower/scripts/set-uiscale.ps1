# Sets the Windower menu scale before the launcher opens.
# The launcher reads C:\Windower4\settings.xml when it loads a profile.
# 1080 -> 1.2, 1440 -> 1.5. Same values as //fit 1080 and //fit 1440.
#
# Run with the Windower launcher closed:
#   & C:\Windower4\scripts\set-uiscale.ps1 1440

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('1080', '1440')]
    [string]$Monitor
)

$ErrorActionPreference = 'Stop'

$scale = if ($Monitor -eq '1440') { '1.5' } else { '1.2' }
$path = 'C:\Windower4\settings.xml'

$busy = @(Get-Process -Name Windower, pol -ErrorAction SilentlyContinue)
if ($busy.Count -gt 0) {
    Write-Error "Close Windower first. An open launcher writes the old menu scale back over $path."
    exit 1
}

if (-not (Test-Path -LiteralPath $path)) {
    Write-Error "Windower settings not found: $path"
    exit 1
}

$utf8 = New-Object System.Text.UTF8Encoding $false
$text = [System.IO.File]::ReadAllText($path)
$pattern = [regex]'<uiscale>([^<]*)</uiscale>'
$found = $pattern.Matches($text)
if ($found.Count -ne 1) {
    Write-Error "Expected one <uiscale> tag in $path, found $($found.Count)."
    exit 1
}

$current = $found[0].Groups[1].Value
if ($current -eq $scale) {
    Write-Output "Menu scale is already $scale for the $Monitor monitor."
    exit 0
}

$updated = $pattern.Replace($text, "<uiscale>$scale</uiscale>", 1)
[System.IO.File]::WriteAllText($path, $updated, $utf8)
Write-Output "Menu scale $current -> $scale for the $Monitor monitor."
Write-Output "Open Windower, load the profile, and start the game."
