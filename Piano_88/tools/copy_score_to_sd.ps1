param(
    [ValidatePattern('^[D-Zd-z]$')]
    [string]$DriveLetter = 'H',
    [switch]$Replace
)
$ErrorActionPreference = 'Stop'
$source = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\sd_card\score\PIANO.BIN')).Path
$drive = [System.IO.DriveInfo]::new($DriveLetter + ':\')
if (-not $drive.IsReady -or $drive.DriveType -ne 'Removable' -or
    $drive.DriveFormat -notin @('FAT', 'FAT16', 'FAT32')) {
    throw 'Expected a ready, removable FAT16/FAT32 SD card.'
}
$bytes = [System.IO.File]::ReadAllBytes($source)
if ([System.Text.Encoding]::ASCII.GetString($bytes, 0, 4) -ne 'P88S' -or
    $bytes.Length -ne 16 + 8 * [BitConverter]::ToUInt32($bytes, 12)) {
    throw 'Source is not a valid P88S score.'
}
if ($drive.AvailableFreeSpace -lt $bytes.Length) { throw 'Insufficient free space.' }
$destination = $DriveLetter.ToUpper() + ':\PIANO.BIN'
$expected = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash
if (Test-Path -LiteralPath $destination) {
    $oldHash = (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash
    if ($oldHash -eq $expected) {
        Write-Output "Already verified: $destination ($expected)"
        exit 0
    }
    if (-not $Replace) { throw 'PIANO.BIN differs. Use -Replace to back it up and replace it.' }
    $backupDir = Join-Path $PSScriptRoot '..\output\sd_backup'
    [void](New-Item -ItemType Directory -Path $backupDir -Force)
    $backup = Join-Path $backupDir ('PIANO_' + (Get-Date -Format 'yyyyMMdd_HHmmss') + '.BIN')
    Copy-Item -LiteralPath $destination -Destination $backup
    if ((Get-FileHash -LiteralPath $backup -Algorithm SHA256).Hash -ne $oldHash) {
        throw 'Existing file backup failed verification.'
    }
    Write-Output "Previous card file backed up: $backup"
}
Copy-Item -LiteralPath $source -Destination $destination -Force
if ((Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash -ne $expected) {
    throw 'SD card readback SHA256 mismatch.'
}
Get-Item -LiteralPath $destination | Select-Object FullName, Length
Write-Output "Score SHA256 verified: $expected"
