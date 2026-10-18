$ErrorActionPreference = 'Stop'
$outputDir = Join-Path $PSScriptRoot '..\output\sd_bin_led_test'
[void](New-Item -ItemType Directory -Path $outputDir -Force)

function Set-U16([byte[]]$Image, [int]$Offset, [uint16]$Value) {
    [Array]::Copy([BitConverter]::GetBytes($Value), 0, $Image, $Offset, 2)
}
function Set-U32([byte[]]$Image, [int]$Offset, [uint32]$Value) {
    [Array]::Copy([BitConverter]::GetBytes($Value), 0, $Image, $Offset, 4)
}

foreach ($fat32 in @($false, $true)) {
    $image = New-Object byte[] 400000
    $volume = 0
    if ($fat32) {
        $volume = 32
        $image[450] = 0x0c
        Set-U32 $image 454 $volume
        Set-U32 $image 458 70000
        $image[510] = 0x55
        $image[511] = 0xaa
    }
    $boot = $volume * 512
    $image[$boot] = 0xeb
    Set-U16 $image ($boot + 11) 512
    $image[$boot + 13] = 1
    $image[$boot + 510] = 0x55
    $image[$boot + 511] = 0xaa
    if ($fat32) {
        Set-U16 $image ($boot + 14) 32
        $image[$boot + 16] = 1
        Set-U32 $image ($boot + 32) 70000
        Set-U32 $image ($boot + 36) 550
        Set-U32 $image ($boot + 44) 2
        $fat = ($volume + 32) * 512
        $directory = ($volume + 32 + 550) * 512
        $firstData = $directory + 512
        $secondData = $directory + 3 * 512
        $firstCluster = 3
        Set-U32 $image ($fat + 8) 0x0fffffff
        Set-U32 $image ($fat + 12) 5
        Set-U32 $image ($fat + 20) 0x0fffffff
        $name = 'fat32_mbr.hex'
    } else {
        Set-U16 $image ($boot + 14) 1
        $image[$boot + 16] = 2
        Set-U16 $image ($boot + 17) 16
        Set-U16 $image ($boot + 19) 8192
        Set-U16 $image ($boot + 22) 32
        $directory = 65 * 512
        $firstData = 66 * 512
        $secondData = 69 * 512
        $firstCluster = 2
        foreach ($fat in @(512, 33 * 512)) {
            Set-U16 $image ($fat + 4) 5
            Set-U16 $image ($fat + 10) 0xffff
        }
        $name = 'fat16_volume.hex'
    }
    $shortName = [Text.Encoding]::ASCII.GetBytes('SDTEST  BIN')
    [Array]::Copy($shortName, 0, $image, $directory, 11)
    $image[$directory + 11] = 0x20
    Set-U16 $image ($directory + 26) $firstCluster
    Set-U32 $image ($directory + 28) 1024
    for ($i = 0; $i -lt 512; $i++) {
        $image[$firstData + $i] = [byte]($i -band 0xff)
        $image[$secondData + $i] = [byte]($i -band 0xff)
    }
    $lines = New-Object string[] $image.Length
    for ($i = 0; $i -lt $image.Length; $i++) {
        $lines[$i] = $image[$i].ToString('X2')
    }
    [IO.File]::WriteAllLines((Join-Path $outputDir $name), $lines, [Text.Encoding]::ASCII)
}
Write-Output "Created FAT16 super-floppy and FAT32 MBR fixtures in $outputDir"
