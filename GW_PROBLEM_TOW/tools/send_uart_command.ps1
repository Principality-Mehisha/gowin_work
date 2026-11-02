param(
    [ValidateSet('NumberedPiano', 'NumberedMarimba', 'Stop', 'Query', 'NotePrevious', 'NoteNext', 'NotePlay', 'InstrumentPiano', 'InstrumentMarimba', 'ViewWaterfall', 'ViewSpectrum', 'ViewWaveform', 'EffectOriginal', 'EffectDelay', 'EffectReverb', 'EffectChorus', 'EffectAmount')]
    [string]$Command = 'Query',
    [ValidateRange(0,255)][int]$Sequence = 0,
    [string]$Port,
    [ValidateRange(1200,1000000)][int]$BaudRate = 115200,
    [ValidateRange(1,100)][int]$Number = 1,
    [ValidateRange(0,100)][int]$Amount = 30
)
$ErrorActionPreference = 'Stop'
$commandByte = 0x01
$track = 0
$p1 = 0
switch ($Command) {
    'NumberedPiano' { $commandByte = 0x12; $track = 1; $p1 = $Number }
    'NumberedMarimba' { $commandByte = 0x12; $track = 2; $p1 = $Number }
    'Stop' { $commandByte = 0x11 }
    'Query' { $commandByte = 0x01 }
    'NotePrevious' { $commandByte = 0x40 }
    'NoteNext' { $commandByte = 0x41 }
    'NotePlay' { $commandByte = 0x42 }
    'InstrumentPiano' { $commandByte = 0x43 }
    'InstrumentMarimba' { $commandByte = 0x44 }
    'ViewWaterfall' { $commandByte = 0x50; $track = 0 }
    'ViewSpectrum' { $commandByte = 0x50; $track = 1 }
    'ViewWaveform' { $commandByte = 0x50; $track = 2 }
    'EffectOriginal' { $commandByte = 0x51; $track = 0 }
    'EffectDelay' { $commandByte = 0x51; $track = 1 }
    'EffectReverb' { $commandByte = 0x51; $track = 2 }
    'EffectChorus' { $commandByte = 0x51; $track = 3 }
    'EffectAmount' { $commandByte = 0x52; $track = $Amount }
}
$checksum = (1 + $Sequence + $commandByte + $track + $p1) -band 255
[byte[]]$frame = 0xA5,0x5A,1,$Sequence,$commandByte,$track,$p1,0,$checksum,0x0D
Write-Output (($frame | ForEach-Object { $_.ToString('X2') }) -join ' ')
if (-not $Port) { return }
# Opens a COM port only when explicitly named by the caller.
$serial = New-Object System.IO.Ports.SerialPort $Port,$BaudRate,None,8,One
$serial.Handshake = [System.IO.Ports.Handshake]::None
$serial.DtrEnable = $false
$serial.RtsEnable = $false
try {
    $serial.Open()
    $serial.Write($frame,0,$frame.Length)
    Start-Sleep -Milliseconds 500
    $received = New-Object 'System.Collections.Generic.List[byte]'
    while ($serial.BytesToRead -gt 0) { $received.Add([byte]$serial.ReadByte()) }
    if ($received.Count -gt 0) {
        Write-Output ([Text.Encoding]::GetEncoding(936).GetString($received.ToArray()))
        Write-Output ('RX HEX: ' + (($received | ForEach-Object { $_.ToString('X2') }) -join ' '))
    }
} finally { if ($serial.IsOpen) { $serial.Close() }; $serial.Dispose() }
