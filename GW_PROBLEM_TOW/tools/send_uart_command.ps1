param(
    [ValidateSet('Android', 'Apple', 'Piano', 'Stop', 'Query', 'NotePrevious', 'NoteNext', 'NotePlay')]
    [string]$Command = 'Query',
    [ValidateRange(0,255)][int]$Sequence = 0,
    [string]$Port
)
$ErrorActionPreference = 'Stop'
$commandByte = 0x10
$track = 0
switch ($Command) {
    'Android' { $track = 1 }
    'Apple' { $track = 2 }
    'Piano' { $track = 3 }
    'Stop' { $commandByte = 0x11 }
    'Query' { $commandByte = 0x01 }
    'NotePrevious' { $commandByte = 0x40 }
    'NoteNext' { $commandByte = 0x41 }
    'NotePlay' { $commandByte = 0x42 }
}
$checksum = (1 + $Sequence + $commandByte + $track) -band 255
[byte[]]$frame = 0xA5,0x5A,1,$Sequence,$commandByte,$track,0,0,$checksum,0x0D
Write-Output (($frame | ForEach-Object { $_.ToString('X2') }) -join ' ')
if (-not $Port) { return }
# Opens a COM port only when explicitly named by the caller.
$serial = New-Object System.IO.Ports.SerialPort $Port,9600,None,8,One
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
        Write-Output ([Text.Encoding]::ASCII.GetString($received.ToArray()).Replace([string][char]127,'?'))
        Write-Output ('RX HEX: ' + (($received | ForEach-Object { $_.ToString('X2') }) -join ' '))
    }
} finally { if ($serial.IsOpen) { $serial.Close() }; $serial.Dispose() }
