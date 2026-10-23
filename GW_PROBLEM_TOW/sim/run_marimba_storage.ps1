param([string]$ReferenceRtl = 'output/marimba_storage/before/marimba_synth_reference.v')
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $projectRoot 'tools/project_sources.ps1')
Push-Location $projectRoot
try {
    if (-not (Test-Path -LiteralPath $ReferenceRtl -PathType Leaf)) { throw 'Supply the pre-change RTL renamed to module marimba_synth_reference using -ReferenceRtl.' }
    if (-not (Test-Path sim/storage_work)) { & vlib sim/storage_work; if ($LASTEXITCODE -ne 0) { throw 'vlib failed' } }
    $sources = Get-ProjectSources $projectRoot
    & vlog -sv -work sim/storage_work @sources $ReferenceRtl sim/tb_marimba_storage.sv
    if ($LASTEXITCODE -ne 0) { throw 'Storage equivalence compilation failed' }
    & vsim -c -voptargs=+acc -lib sim/storage_work tb_marimba_storage -do 'onfinish stop; run -all; if {[examine -radix unsigned /tb_marimba_storage/passed] != 1} {quit -code 1 -f}; quit -code 0 -f' -l sim/tb_marimba_storage.log
    if ($LASTEXITCODE -ne 0) { throw 'Storage equivalence failed' }
} finally { Pop-Location }
