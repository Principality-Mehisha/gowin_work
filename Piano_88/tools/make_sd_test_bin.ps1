$ErrorActionPreference = 'Stop'
$output = Join-Path $PSScriptRoot '..\sd_card\SDTEST.BIN'
$bytes = New-Object byte[] 1024
for ($i = 0; $i -lt $bytes.Length; $i++) {
    $bytes[$i] = [byte]($i -band 0xff)
}
[System.IO.File]::WriteAllBytes((Resolve-Path (Split-Path $output -Parent)).Path + '\SDTEST.BIN', $bytes)
Get-Item -LiteralPath $output | Select-Object FullName, Length
