$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $projectRoot 'tools/project_sources.ps1')
Push-Location $projectRoot
try {
    if (-not (Test-Path sim/audio_work)) { & vlib sim/audio_work; if ($LASTEXITCODE -ne 0) { throw 'vlib failed' } }
    $sources = Get-ProjectSources $projectRoot
    & vlog -sv -work sim/audio_work @sources sim/tb_marimba_wav.sv
    if ($LASTEXITCODE -ne 0) { throw 'Audio compilation failed' }
    & vsim -c -voptargs=+acc -lib sim/audio_work tb_marimba_wav -do 'onfinish stop; run -all; if {[examine -radix unsigned /tb_marimba_wav/passed] != 1} {quit -code 1 -f}; quit -code 0 -f' -l sim/tb_marimba_wav.log
    if ($LASTEXITCODE -ne 0) { throw 'Audio rendering failed' }
    & python tools/check_marimba_audio.py
    if ($LASTEXITCODE -ne 0) { throw 'Marimba audio verification failed' }
    & python tools/export_marimba_wav.py
    if ($LASTEXITCODE -ne 0) { throw 'Marimba WAV export failed' }
} finally { Pop-Location }
