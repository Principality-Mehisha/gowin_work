param(
    [ValidatePattern('^[D-Zd-z]$')]
    [string]$DriveLetter = 'H'
)
$ErrorActionPreference = 'Stop'
$startedAt = Get-Date
$partition = Get-Partition -DriveLetter $DriveLetter
$disk = $partition | Get-Disk
$volume = Get-Volume -DriveLetter $DriveLetter
if ($disk.BusType -notin @('USB','SD','MMC') -or
    $disk.Size -lt 800000000 -or $disk.Size -gt 1200000000 -or
    $disk.LogicalSectorSize -ne 512 -or $volume.FileSystem -ne 'FAT32' -or
    $partition.Offset -ne 16384) {
    throw 'Expected the verified approximately 1GB FAT32 SD card, partition offset 16384.'
}
$outputDir = Join-Path $PSScriptRoot ('..\output\sd_music_test\audit_' + (Get-Date -Format 'yyyyMMdd_HHmmss'))
$outputDir = [System.IO.Path]::GetFullPath($outputDir)
Add-Type -Path (Join-Path $PSScriptRoot 'SdCardReadOnlyAudit.cs')
$report = [SdCardReadOnlyAudit]::Run(
    ('\\.\' + $DriveLetter.ToUpper() + ':'), $partition.Size,
    [long]($partition.Offset / 512), $outputDir)
$report['Disk'] = @{
    Number = $disk.Number
    Bytes = $disk.Size
    Model = $disk.Model
    BusType = [string]$disk.BusType
    PartitionStyle = [string]$disk.PartitionStyle
    PartitionBytes = $partition.Size
}
$reportPath = Join-Path $outputDir 'report.json'
$report | ConvertTo-Json -Depth 15 | Set-Content -LiteralPath $reportPath -Encoding utf8
try {
    $report['RootFiles'] = @(Get-ChildItem -LiteralPath ($DriveLetter + ':\') -Force |
        Select-Object Name, Length, Attributes)
    $report['PianoMountedSha256'] = (Get-FileHash -LiteralPath ($DriveLetter + ':\PIANO.BIN')).Hash
} catch {
    $report['MountedAccessError'] = $_.Exception.Message
}
$report['PianoOriginalSha256'] = (Get-FileHash -LiteralPath (
    Join-Path $PSScriptRoot '..\sd_card\music\PIANO.BIN')).Hash
$report['RecentStorageEvents'] = @(Get-WinEvent -FilterHashtable @{
    LogName = 'System'; StartTime = $startedAt.AddMinutes(-10)
} -MaxEvents 300 -ErrorAction SilentlyContinue |
    Where-Object { $_.ProviderName -match '^(disk|partmgr|Microsoft-Windows-StorPort)$' } |
    Select-Object TimeCreated, ProviderName, Id, Message)
$report['StartedAt'] = $startedAt.ToString('o')
$report['FinishedAt'] = (Get-Date).ToString('o')
$report | ConvertTo-Json -Depth 15 | Set-Content -LiteralPath $reportPath -Encoding utf8
[pscustomobject]@{
    Report = $reportPath
    Passes = @($report['Passes'] | ForEach-Object {
        [pscustomobject]@{
            Pass = $_['Pass']; BytesRead = $_['BytesRead']; Complete = $_['Complete']
            Sha256 = $_['Sha256']; DifferingBlocks = $_['DifferingBlocks']
        }
    })
    Issues = $report['Issues']
    SectorAlignedSignatureMatches = $report['SectorAligned2ABF'].Count
    ArbitraryWindowMatches = $report['AnyAlignment88_2ABF'].Count
    PianoMountedSha256 = $report['PianoMountedSha256']
    PianoOriginalSha256 = $report['PianoOriginalSha256']
} | ConvertTo-Json -Depth 5
