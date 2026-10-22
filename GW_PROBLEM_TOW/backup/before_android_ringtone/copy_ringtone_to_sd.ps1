param([ValidatePattern('^[D-Zd-z]$')][string]$DriveLetter='H')
$ErrorActionPreference='Stop'
$projectRoot=Split-Path -Parent $PSScriptRoot
$source=Join-Path $projectRoot 'sd_card\RINGTONE.BIN'
$drive=[System.IO.DriveInfo]::new($DriveLetter+':\')
if(-not $drive.IsReady -or $drive.DriveType -ne 'Removable' -or $drive.DriveFormat -notin @('FAT','FAT16','FAT32')){throw 'Expected removable FAT16/FAT32 SD card'}
$bytes=[System.IO.File]::ReadAllBytes($source)
if($bytes.Length -lt 24 -or [Text.Encoding]::ASCII.GetString($bytes,0,4) -ne 'M42S' -or $bytes.Length -ne 16+8*[BitConverter]::ToUInt32($bytes,12)){throw 'Invalid M42S source'}
$dest=$DriveLetter.ToUpper()+':\RINGTONE.BIN'
$piano=$DriveLetter.ToUpper()+':\PIANO.BIN'
$pianoHash=if(Test-Path -LiteralPath $piano){(Get-FileHash -LiteralPath $piano -Algorithm SHA256).Hash}else{$null}
$hash=(Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash
if(Test-Path -LiteralPath $dest){
 $old=(Get-FileHash -LiteralPath $dest -Algorithm SHA256).Hash
 if($old -ne $hash){
  $backupDir=Join-Path $projectRoot 'output\sd_backup';New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
  $backup=Join-Path $backupDir ('RINGTONE_'+(Get-Date -Format 'yyyyMMdd_HHmmss')+'.BIN')
  Copy-Item -LiteralPath $dest -Destination $backup
  if((Get-FileHash -LiteralPath $backup -Algorithm SHA256).Hash -ne $old){throw 'Backup verification failed'}
 }
}
$stream=[IO.FileStream]::new($dest,[IO.FileMode]::Create,[IO.FileAccess]::Write,[IO.FileShare]::None,4096,[IO.FileOptions]::WriteThrough)
try{$stream.Write($bytes,0,$bytes.Length);$stream.Flush($true)}finally{$stream.Dispose()}
if((Get-FileHash -LiteralPath $dest -Algorithm SHA256).Hash -ne $hash){throw 'SD readback mismatch'}
if($pianoHash -and (Get-FileHash -LiteralPath $piano -Algorithm SHA256).Hash -ne $pianoHash){throw 'PIANO.BIN changed unexpectedly'}
$report=@{destination=$dest;bytes=$bytes.Length;sha256=$hash;piano_sha256_unchanged=$pianoHash;verified_at=(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')}
$report | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $projectRoot 'sd_card\RINGTONE_SD_WRITE.json') -Encoding utf8
$report | ConvertTo-Json
