param(
    [Parameter(Mandatory=$true)]
    [ValidatePattern('^[D-Zd-z]$')]
    [string]$DriveLetter,
    [switch]$Replace
)
$ErrorActionPreference = 'Stop'
$musicPath = Join-Path $PSScriptRoot '..\sd_card\music\MUSIC.WAV'
$musicPath = (Resolve-Path -LiteralPath $musicPath).Path
$volume = Get-Volume -DriveLetter $DriveLetter
$partition = Get-Partition -DriveLetter $DriveLetter
$disk = $partition | Get-Disk
if ($disk.BusType -notin @('USB','SD','MMC') -or
    $disk.Size -lt 800000000 -or $disk.Size -gt 1200000000) {
    throw "Target must be the approximately 1GB SD card on USB/SD/MMC."
}
if ($volume.FileSystem -notin @('FAT','FAT16','FAT32')) {
    throw "FAT16/FAT32 required. This script does not format cards."
}
if ($volume.SizeRemaining -lt (Get-Item -LiteralPath $musicPath).Length) {
    throw "Insufficient free space."
}
$destination = "$($DriveLetter.ToUpper()):\MUSIC.WAV"
$expected = (Get-FileHash -LiteralPath $musicPath -Algorithm SHA256).Hash
if (Test-Path -LiteralPath $destination) {
    if ((Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash -eq $expected) {
        Write-Output "Already present and verified: $destination"
        exit 0
    }
    if (-not $Replace) {
        throw "MUSIC.WAV already exists with different content. Use -Replace only after reviewing it."
    }
}
Copy-Item -LiteralPath $musicPath -Destination $destination -Force:$Replace
if ((Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash -ne $expected) {
    throw "Copied file failed SHA256 verification."
}
Get-Item -LiteralPath $destination | Select-Object FullName,Length,LastWriteTime
Write-Output "SHA256 verified: $expected"
