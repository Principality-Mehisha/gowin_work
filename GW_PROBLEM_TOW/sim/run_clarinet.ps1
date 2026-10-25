$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $projectRoot 'tools/project_sources.ps1')
Push-Location $projectRoot
try {
    & python tools/check_project.py
    if ($LASTEXITCODE -ne 0) { throw 'Project check failed' }
    & python tools/make_test_fixtures.py
    if ($LASTEXITCODE -ne 0) { throw 'Fixture generation failed' }
    New-Item -ItemType Directory -Force output/clarinet | Out-Null
    if (-not (Test-Path sim/clarinet_work)) {
        & vlib sim/clarinet_work
        if ($LASTEXITCODE -ne 0) { throw 'vlib failed' }
    }
    $sources = Get-ProjectSources $projectRoot
    # tb_uart_player supplies the existing behavioral Gowin GSR primitive.
    & vlog -sv +incdir+sim -work sim/clarinet_work @sources sim/sd_card_model.v sim/tb_uart_player.sv sim/tb_clarinet.sv sim/tb_note_audition.sv sim/tb_tjc_status.sv sim/tb_uart_notes.sv
    if ($LASTEXITCODE -ne 0) { throw 'vlog failed' }
    foreach ($bench in @('tb_clarinet','tb_note_audition','tb_tjc_status','tb_uart_notes')) {
        $commands = 'onfinish stop; run -all; if {[examine -radix unsigned /' + $bench + '/passed] != 1} {quit -code 1 -f}; quit -code 0 -f'
        & vsim -c -voptargs=+acc -lib sim/clarinet_work $bench -do $commands -l "output/clarinet/$bench.log"
        if ($LASTEXITCODE -ne 0) { throw "$bench failed" }
    }
    & python tools/check_clarinet_audio.py
    if ($LASTEXITCODE -ne 0) { throw 'Clarinet audio check failed' }
} finally { Pop-Location }
