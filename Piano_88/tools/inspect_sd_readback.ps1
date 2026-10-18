param(
    [ValidatePattern('^[D-Zd-z]$')]
    [string]$DriveLetter = 'H'
)
$ErrorActionPreference = 'Stop'
$partition = Get-Partition -DriveLetter $DriveLetter
$disk = $partition | Get-Disk
$volume = Get-Volume -DriveLetter $DriveLetter
if ($disk.BusType -notin @('USB','SD','MMC') -or
    $disk.Size -lt 800000000 -or $disk.Size -gt 1200000000 -or
    $disk.LogicalSectorSize -ne 512 -or $volume.FileSystem -ne 'FAT32') {
    throw 'Expected the verified approximately 1GB FAT32 SD card.'
}
$outputDir = Join-Path $PSScriptRoot '..\output\sd_music_test\card_readback'
[void][System.IO.Directory]::CreateDirectory($outputDir)
$capturePath = Join-Path $outputDir 'volume_first_16MiB.bin'
$devicePath = '\\.\' + $DriveLetter.ToUpper() + ':'
$source = [System.IO.File]::Open(
    $devicePath, [System.IO.FileMode]::Open,
    [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
try {
    $bytes = New-Object byte[] (16 * 1024 * 1024)
    $offset = 0
    while ($offset -lt $bytes.Length) {
        $count = $source.Read($bytes, $offset, $bytes.Length - $offset)
        if ($count -eq 0) { throw 'Short SD read.' }
        $offset += $count
    }
} finally {
    $source.Dispose()
}
[System.IO.File]::WriteAllBytes($capturePath, $bytes)
$boot = [byte[]]$bytes[0..511]
$physicalStart = [long]($partition.Offset / 512)
$matches = @(
    for ($offset = 0; $offset -lt $bytes.Length; $offset += 512) {
        if ($bytes[$offset + 510] -eq 0x2a -and $bytes[$offset + 511] -eq 0xbf) {
            [pscustomobject]@{
                PhysicalLba = $physicalStart + $offset / 512
                First16 = [BitConverter]::ToString($bytes, $offset, 16)
                Last16 = [BitConverter]::ToString($bytes, $offset + 496, 16)
            }
        }
    }
)
$fixture = [System.Collections.Generic.List[string]]::new()
$fixture.Add(('@{0:X8}' -f ($physicalStart * 512)))
for ($offset = 0; $offset -lt 512; $offset += 16) {
    $fixture.Add([BitConverter]::ToString($boot, $offset, 16).Replace('-', ' '))
}
[System.IO.File]::WriteAllLines((Join-Path $outputDir 'boot.hex'), $fixture)
[int]$crc = 0
foreach ($value in $boot) {
    $crc = $crc -bxor ([int]$value -shl 8)
    for ($bit = 0; $bit -lt 8; $bit++) {
        $crc = if ($crc -band 0x8000) {
            (($crc -shl 1) -bxor 0x1021) -band 0xffff
        } else {
            ($crc -shl 1) -band 0xffff
        }
    }
}
$report = [pscustomobject]@{
    DiskNumber = $disk.Number
    DiskBytes = $disk.Size
    VolumeStartLba = $physicalStart
    BootFirst16 = [BitConverter]::ToString($boot, 0, 16)
    BootSignature = [BitConverter]::ToString($boot, 510, 2)
    BootCrc16 = '{0:X4}' -f $crc
    FPGAReportedSignature = '2A-BF'
    MatchingSectorsInFirst16MiB = $matches
    PianoSha256 = (Get-FileHash -LiteralPath ($DriveLetter + ':\PIANO.BIN')).Hash
    CapturePath = [System.IO.Path]::GetFullPath($capturePath)
}
$json = $report | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText((Join-Path $outputDir 'report.json'), $json)
$json
