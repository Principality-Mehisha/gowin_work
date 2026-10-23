$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $projectRoot 'tools/project_sources.ps1')
Push-Location $projectRoot
try {
    & python tools/make_test_fixtures.py
    if ($LASTEXITCODE -ne 0) { throw 'Fixture generation failed' }
    if (-not (Test-Path sim/work_score)) { & vlib sim/work_score; if ($LASTEXITCODE -ne 0) { throw 'vlib failed' } }
    $sources = Get-ProjectSources $projectRoot
    & vlog -sv -work sim/work_score @sources sim/sd_card_model.v sim/tb_score_full.v sim/tb_score_player.v
    if ($LASTEXITCODE -ne 0) { throw 'vlog failed' }
    Push-Location sim
    try {
        foreach ($bench in @('tb_score_full','tb_score_player')) {
            $commands = 'onfinish stop; run -all; if {[examine -radix unsigned /' + $bench + '/passed] != 1} {quit -code 1 -f}; quit -code 0 -f'
            & vsim -c -voptargs=+acc -lib work_score $bench -do $commands -l "${bench}.log"
            if ($LASTEXITCODE -ne 0) { throw "$bench failed" }
        }
    } finally { Pop-Location }
} finally { Pop-Location }
