$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $projectRoot 'tools/project_sources.ps1')
Push-Location $projectRoot
try {
    if (-not (Test-Path sim/work)) { & vlib sim/work; if ($LASTEXITCODE -ne 0) { throw 'vlib failed' } }
    $sources = Get-ProjectSources $projectRoot
    New-Item -ItemType Directory -Force output/clarinet_calibration | Out-Null
    & vlog -sv -work sim/work @sources sim/tb_marimba_controls.sv sim/tb_synth.sv sim/tb_marimba.sv sim/tb_clarinet.sv sim/tb_keys.sv sim/tb_dac.sv sim/tb_limiter.sv
    if ($LASTEXITCODE -ne 0) { throw 'vlog failed' }
    foreach ($bench in @('tb_keys','tb_limiter','tb_dac','tb_synth','tb_marimba','tb_marimba_controls','tb_clarinet')) {
        $commands = 'onfinish stop; run -all; if {[examine -radix unsigned /' + $bench + '/passed] != 1} {quit -code 1 -f}; quit -code 0 -f'
        & vsim -c -voptargs=+acc -lib sim/work $bench -do $commands -l "sim/${bench}.log"
        if ($LASTEXITCODE -ne 0) { throw "$bench failed" }
    }
} finally { Pop-Location }
